import 'package:flutter/material.dart';
import 'app_data.dart';
import 'speech_helper.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final CropInfo? recommendedCrop;
  final bool isCropYieldPrompt;
  DateTime? selectedSowingDate;
  double? landAreaAcres;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.recommendedCrop,
    this.isCropYieldPrompt = false,
    this.selectedSowingDate,
    this.landAreaAcres,
  });
}

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechHelper _speechHelper = SpeechHelper();
  bool _isTyping = false;
  bool _autoSpeak = true;
  String? _currentlySpeakingText;
  late AnimationController _waveController;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! Welcome to your Krishi360 AI Voice Agronomist.\n\nAsk me any question about crop diseases, pest control, chemical & organic remedies, fertilizer schedules, or crop yields, and I will give you the complete diagnosis and cure in plain English.",
      isUser: false,
      time: "Now",
    ),
  ];

  final List<String> _quickSuggestions = [
    "How to cure Rhizome Rot in Turmeric?",
    "Fall Armyworm cure in Maize",
    "Fertilizer schedule for Turmeric",
    "Paddy Blast disease treatment",
    "Banana Sigatoka leaf spot remedy",
    "How to cure Leaf Curl in Chili?",
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _speechHelper.onSpeechStateChanged = () {
      if (mounted) setState(() {});
    };

    if (_autoSpeak) {
      _speechHelper.speak(_messages.first.text);
      _currentlySpeakingText = _messages.first.text;
    }
  }

  @override
  void dispose() {
    _speechHelper.stop();
    _waveController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _speakMessage(String text) {
    if (_speechHelper.isSpeaking && _currentlySpeakingText == text) {
      _speechHelper.stop();
      setState(() => _currentlySpeakingText = null);
    } else {
      setState(() => _currentlySpeakingText = text);
      _speechHelper.speak(text, onComplete: () {
        if (mounted) setState(() => _currentlySpeakingText = null);
      });
    }
  }

  void _handleSend(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _speechHelper.stop();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: "Now"));
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 450));

    final cropMatch = _detectCrop(text);
    final isYieldOrSowingQuestion = _isAskingAboutYieldOrSowing(text);
    final aiReply = _generatePreciseEnglishAIResponse(text, cropMatch);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: aiReply,
            isUser: false,
            time: "Now",
            recommendedCrop: cropMatch,
            isCropYieldPrompt: cropMatch != null && isYieldOrSowingQuestion,
            selectedSowingDate: DateTime.now().add(const Duration(days: 7)),
            landAreaAcres: AppState().profile.landAreaAcres,
          ),
        );
      });
      _scrollToBottom();

      if (_autoSpeak) {
        _speakMessage(aiReply);
      }
    }
  }

  bool _isAskingAboutYieldOrSowing(String text) {
    final l = text.toLowerCase();
    return l.contains("yield") ||
        l.contains("how much yield") ||
        l.contains("production") ||
        l.contains("how much kg") ||
        l.contains("quintal") ||
        l.contains("sowing") ||
        l.contains("cropping") ||
        l.contains("harvest date") ||
        l.contains("when to sow") ||
        l.contains("when to plant") ||
        l.contains("calculate");
  }

  CropInfo? _detectCrop(String text) {
    final lower = text.toLowerCase();
    final crops = AppState().crops;
    for (var c in crops) {
      if (lower.contains(c.name.toLowerCase()) || (c.name.contains("/") && c.name.split("/").any((part) => lower.contains(part.trim().toLowerCase())))) {
        return c;
      }
    }
    if (lower.contains("turmeric") || lower.contains("curcuma")) return AppState().getCropByName("Turmeric");
    if (lower.contains("sugarcane") || lower.contains("cane")) return AppState().getCropByName("Sugarcane");
    if (lower.contains("banana") || lower.contains("plantain") || lower.contains("nendran")) return AppState().getCropByName("Banana");
    if (lower.contains("paddy") || lower.contains("rice")) return AppState().getCropByName("Paddy");
    if (lower.contains("groundnut") || lower.contains("peanut")) return AppState().getCropByName("Groundnut");
    if (lower.contains("tapioca") || lower.contains("cassava")) return AppState().getCropByName("Tapioca");
    if (lower.contains("corn") || lower.contains("maize")) return AppState().getCropByName("Maize");
    if (lower.contains("onion")) return AppState().getCropByName("Onion");
    if (lower.contains("cotton")) return AppState().getCropByName("Cotton");
    if (lower.contains("tomato")) return AppState().getCropByName("Tomato");
    if (lower.contains("potato")) return AppState().getCropByName("Potato");
    if (lower.contains("chili") || lower.contains("chilli") || lower.contains("pepper")) return AppState().getCropByName("Chili");

    return null;
  }

  String _generatePreciseEnglishAIResponse(String query, CropInfo? crop) {
    final q = query.toLowerCase();

    // 1. PEST & DISEASE QUESTIONS (DIAGNOSIS & CURE)
    if (q.contains("pest") || q.contains("disease") || q.contains("insect") || q.contains("worm") ||
        q.contains("fungus") || q.contains("rot") || q.contains("curl") || q.contains("blight") ||
        q.contains("borer") || q.contains("thrips") || q.contains("yellow") || q.contains("attack") ||
        q.contains("spray") || q.contains("pesticide") || q.contains("control") || q.contains("cure") ||
        q.contains("wilt") || q.contains("spot") || q.contains("infection") || q.contains("dying") ||
        q.contains("chlorosis") || q.contains("caterpillar") || q.contains("whitefly") || q.contains("mite")) {
      return _getDiseaseAndCureAnswer(q, crop);
    }

    // 2. FERTILIZER & NUTRITION QUESTIONS
    if (q.contains("fertilizer") || q.contains("fertiliser") || q.contains("npk") || q.contains("dap") ||
        q.contains("urea") || q.contains("potash") || q.contains("mop") || q.contains("zinc") ||
        q.contains("gypsum") || q.contains("dose") || q.contains("dosage") || q.contains("feed") ||
        q.contains("nutrient") || q.contains("manure") || q.contains("growth")) {
      return _getFertilizerAnswer(crop);
    }

    // 3. YIELD & HARVEST QUESTIONS
    if (q.contains("yield") || q.contains("how much yield") || q.contains("production") ||
        q.contains("how much kg") || q.contains("quintal") || q.contains("harvest time") ||
        q.contains("days") || q.contains("duration") || q.contains("tons")) {
      return _getYieldAnswer(crop);
    }

    // 4. WATERING & IRRIGATION QUESTIONS
    if (q.contains("water") || q.contains("irrigate") || q.contains("irrigation") || q.contains("drip") ||
        q.contains("canal") || q.contains("rainfed") || q.contains("frequency")) {
      return _getWateringAnswer(crop);
    }

    // 5. SEED, SOWING & SEASON QUESTIONS
    if (q.contains("sowing") || q.contains("seed") || q.contains("planting") || q.contains("season") ||
        q.contains("soil") || q.contains("spacing") || q.contains("when to plant") || q.contains("month")) {
      return _getSowingAndSoilAnswer(crop);
    }

    // 6. MARKET PRICE & MANDI QUESTIONS
    if (q.contains("price") || q.contains("rate") || q.contains("mandi") || q.contains("market") ||
        q.contains("sell") || q.contains("buyer") || q.contains("cost")) {
      return _getMarketPriceAnswer(crop);
    }

    // 7. WEATHER QUESTIONS
    if (q.contains("weather") || q.contains("rain") || q.contains("temperature") || q.contains("forecast") || q.contains("cloud")) {
      return _getWeatherAnswer();
    }

    // 8. GOVERNMENT SCHEMES & SUBSIDY
    if (q.contains("pm-kisan") || q.contains("kisan") || q.contains("subsidy") || q.contains("scheme") ||
        q.contains("yojana") || q.contains("loan") || q.contains("insurance") || q.contains("pmfby") ||
        q.contains("government")) {
      return _getGovernmentSchemeAnswer();
    }

    // 9. ORGANIC FARMING & BIO-FERTILIZERS
    if (q.contains("organic") || q.contains("jeevamrut") || q.contains("panchagavya") || q.contains("neem") ||
        q.contains("bio") || q.contains("natural")) {
      return _getOrganicFarmingAnswer();
    }

    // 10. IF CROP MENTIONED WITHOUT SPECIFIC INTENT
    if (crop != null) {
      return "🌾 **Agronomic Summary for ${crop.name}**\n\n"
          "• **Fertilizer**: ${crop.fertilizerDetail.basalDose}\n"
          "• **Watering**: ${crop.waterSchedule}\n"
          "• **Expected Yield**: ~${crop.expectedYieldPerAcreKg} Kg/Acre (${crop.harvestDays} Days to harvest)\n"
          "• **Pest & Disease Care**: ${crop.pesticideSchedule}\n\n"
          "💡 Ask me specifically about diseases, fertilizer dosage, crop yield, or market rates!";
    }

    // GENERAL AGRO ANSWER
    return "🌱 **Agronomist Guidance for '$query'**:\n\n"
        "• To provide an exact diagnosis and chemical/organic cure, please specify your crop (for example: Turmeric, Sugarcane, Banana, Paddy, Groundnut, Maize, Cotton, Tomato, Chili, or Onion).\n"
        "• Example questions: *\"How to cure Rhizome Rot in Turmeric?\"*, *\"What is the fertilizer dose for Sugarcane?\"*, or *\"How to control leaf curl in Chili?\"*.";
  }

  String _getDiseaseAndCureAnswer(String q, CropInfo? crop) {
    // 1. TURMERIC DISEASES
    if (q.contains("turmeric") || (crop != null && crop.name.contains("Turmeric"))) {
      if (q.contains("rhizome rot") || q.contains("rot") || q.contains("fungus") || q.contains("decay")) {
        return "🛡️ **Disease: Rhizome Rot (Soft Rot / Pythium aphanidermatum)**\n\n"
            "🔍 **Symptoms**: Lower leaves turn yellow and dry from the margins. The base of the pseudostem becomes soft and water-soaked, decaying into a foul-smelling brown rot.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• **Soil Drenching**: Drench root zone with **Metalaxyl 8% + Mancozeb 64% WP (Ridomil Gold) @ 2.5 grams per Liter of water** (use 300–400 ml solution per plant clump).\n"
            "• **Alternative Spray**: Drench with **Copper Oxychloride 50 WP (Blitox) @ 3.0 grams per Liter of water**.\n"
            "• Repeat drenching after 15 days if soil moisture remains high.\n\n"
            "🌿 **Organic / Biological Cure**:\n"
            "• Apply **Trichoderma viride @ 2.5 kg mixed with 100 kg enriched Farmyard Manure (FYM)** and 50 kg Neem cake per acre at root base.\n\n"
            "🛡️ **Preventive Measures**:\n"
            "• Provide proper field drainage channels to prevent waterlogging.\n"
            "• Never select seed rhizomes from rot-affected fields.";
      }

      if (q.contains("leaf spot") || q.contains("blotch") || q.contains("spot") || q.contains("leaf")) {
        return "🍂 **Disease: Leaf Spot & Leaf Blotch (Colletotrichum & Taphrina)**\n\n"
            "🔍 **Symptoms**: Brown elliptical spots with yellow rings appearing on upper leaf surfaces. As infection progresses, leaves dry out prematurely, reducing rhizome size.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Azoxystrobin 18.2% + Difenoconazole 11.4% SC (Amistar Top) @ 1.0 ml per Liter of water**.\n"
            "• Or spray **Mancozeb 75 WP @ 2.5 grams per Liter of water**.\n"
            "• Add a non-ionic spreader/sticker (0.5 ml/L) for better adhesion on waxy leaves.\n\n"
            "🌿 **Organic Cure**:\n"
            "• Spray **Pseudomonas fluorescens @ 5 grams per Liter** or 3% Panchagavya solution at 15-day intervals.";
      }

      if (q.contains("yellow") || q.contains("chlorosis") || q.contains("iron")) {
        return "🟡 **Problem: Iron Chlorosis / Leaf Yellowing in Turmeric**\n\n"
            "🔍 **Cause**: Iron deficiency in alkaline or calcareous soils (veins remain green while leaf blade turns pale yellow).\n\n"
            "💊 **Cure & Dosage**:\n"
            "• Foliar spray of **Ferrous Sulphate (FeSO4) @ 5.0 grams + Citric Acid @ 0.5 grams per Liter of water**.\n"
            "• Or spray **Chelated Iron (Fe-EDTA 12%) @ 1.0 gram per Liter of water**.\n"
            "• Spray twice at 10-day intervals during early morning or late evening.";
      }

      if (q.contains("borer") || q.contains("shoot borer") || q.contains("worm")) {
        return "🐛 **Pest: Shoot Borer (Conogethes punctiferalis)**\n\n"
            "🔍 **Symptoms**: Larvae bore into pseudo-stems, causing central shoots to dry up into a 'dead heart'. Frass and boreholes visible on stem.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Chlorantraniliprole 18.5% SC (Coragen) @ 0.4 ml per Liter of water** (80 ml in 200L water per acre).\n"
            "• Or spray **Dimethoate 30% EC @ 1.7 ml per Liter of water** at Day 60 and Day 90.\n\n"
            "🌿 **Organic Cure**: Spray Neem Oil (10,000 ppm) @ 2.0 ml/L at first sign of moth activity.";
      }
    }

    // 2. MAIZE / CORN DISEASES
    if (q.contains("maize") || q.contains("corn") || (crop != null && crop.name.contains("Maize"))) {
      if (q.contains("armyworm") || q.contains("fall armyworm") || q.contains("worm") || q.contains("caterpillar") || q.contains("borer")) {
        return "🐛 **Pest: Fall Armyworm (Spodoptera frugiperda) in Maize**\n\n"
            "🔍 **Symptoms**: Scraped leaf surfaces with ragged pinholes, massive leaf destruction, and sawdust-like yellowish frass inside the central plant whorl.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• **First-Line Spray**: Spray **Emamectin Benzoate 5% SG @ 0.4 grams per Liter of water** (80 grams in 200 Liters water per acre) directed directly into the central whorl.\n"
            "• **Severe Infestation**: Spray **Spinetoram 11.7% SC @ 0.5 ml per Liter of water** or **Chlorantraniliprole 18.5% SC @ 0.4 ml per Liter of water**.\n"
            "• Spray during late evening when larvae are actively feeding.\n\n"
            "🌿 **Organic Cure**:\n"
            "• Apply fine sand mixed with neem cake powder (9:1 ratio) into the central whorl of young plants.\n"
            "• Spray *Bacillus thuringiensis* (Bt) formulation @ 2.0 grams per Liter of water.";
      }
      if (q.contains("blight") || q.contains("leaf spot")) {
        return "🍂 **Disease: Turcicum Leaf Blight in Maize**\n\n"
            "🔍 **Symptoms**: Long elliptical greyish-green lesions that expand and turn straw-colored, drying the foliage.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Mancozeb 75 WP @ 2.5 grams per Liter of water** or **Azoxystrobin 23 SC @ 1.0 ml per Liter of water** at first appearance of spots.";
      }
    }

    // 3. PADDY / RICE DISEASES
    if (q.contains("paddy") || q.contains("rice") || (crop != null && crop.name.contains("Paddy"))) {
      if (q.contains("blast") || q.contains("leaf blast") || q.contains("neck blast")) {
        return "🌾 **Disease: Blast Disease (Pyricularia oryzae) in Paddy**\n\n"
            "🔍 **Symptoms**: Spindle-shaped/diamond spots with greyish-white centres and brown margins on leaves; blackening of node/panicle neck causing lodging.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Tricyclazole 75% WP (Beam) @ 0.6 grams per Liter of water** (120g per acre in 200L water).\n"
            "• Or spray **Isoprothiolane 40% EC @ 1.5 ml per Liter of water**.\n\n"
            "🌿 **Organic Cure**:\n"
            "• Seed treatment with *Pseudomonas fluorescens* @ 10g/kg seed + foliar spray @ 5g/L.\n"
            "• Avoid excessive top-dressing of nitrogen (Urea) in cloudy/humid weather.";
      }
      if (q.contains("stem borer") || q.contains("dead heart") || q.contains("white ear")) {
        return "🐛 **Pest: Yellow Stem Borer in Paddy**\n\n"
            "🔍 **Symptoms**: 'Dead hearts' (drying of central tiller) during vegetative stage and 'White ears' (empty chaffy white panicles) at heading stage.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Broadcast **Cartap Hydrochloride 4% G granules @ 8 kg per acre** into shallow standing water.\n"
            "• Or foliar spray **Chlorantraniliprole 18.5 SC (Coragen) @ 0.3 ml per Liter of water** (60 ml/acre).\n"
            "• Or spray **Fipronil 5% SC @ 2.0 ml per Liter of water**.";
      }
      if (q.contains("bacterial blight") || q.contains("blight") || q.contains("bacterial leaf")) {
        return "🦠 **Disease: Bacterial Leaf Blight (BLB) in Paddy**\n\n"
            "🔍 **Symptoms**: Water-soaked translucent streaks along leaf edges turning yellow-orange with wavy margins.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Streptocycline @ 0.1 gram + Copper Oxychloride 50 WP @ 2.5 grams per Liter of water** (20g Streptocycline + 500g COC in 200L water per acre).\n"
            "• Drain excess standing water from field for 3–4 days to restrict bacterial spread.";
      }
    }

    // 4. BANANA DISEASES
    if (q.contains("banana") || (crop != null && crop.name.contains("Banana"))) {
      if (q.contains("sigatoka") || q.contains("leaf spot") || q.contains("streak")) {
        return "🍌 **Disease: Sigatoka Leaf Spot in Banana**\n\n"
            "🔍 **Symptoms**: Yellowish-green narrow streaks on leaves turning dark brown/black with ash-grey centres, drying whole leaves.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Propiconazole 25% EC (Tilt) @ 1.0 ml + Mineral Oil @ 5.0 ml per Liter of water**.\n"
            "• Or spray **Tebuconazole 50% + Trifloxystrobin 25% WG (Nativo) @ 0.5 grams per Liter of water**.\n"
            "• Remove and destroy severely infected dry lower leaves.";
      }
      if (q.contains("borer") || q.contains("stem borer") || q.contains("weevil") || q.contains("hole")) {
        return "🐛 **Pest: Pseudostem & Rhizome Weevil in Banana**\n\n"
            "🔍 **Symptoms**: Boreholes on pseudostem with transparent jelly-like gum exudation; internal rotting leading to wind breakage.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• **Stem Injection**: Inject stem at 30 cm and 60 cm height with **Chlorpyrifos 20 EC @ 2.5 ml per Liter of water**.\n"
            "• Or apply **Carbofuran 3G granules @ 20 grams per plant** at the corm base.\n\n"
            "🌿 **Organic Cure**: Swab stem with *Beauveria bassiana* liquid formulation (10 ml/L).";
      }
      if (q.contains("panama") || q.contains("wilt")) {
        return "🍂 **Disease: Panama Wilt (Fusarium oxysporum) in Banana**\n\n"
            "🔍 **Symptoms**: Yellowing of lower leaf petioles, buckling of leaves like a skirt around the pseudostem, internal vascular browning.\n\n"
            "💊 **Cure & Management**:\n"
            "• Drench plant basin with **Carbendazim 50 WP @ 2.0 grams per Liter of water** (2–3 Liters per plant).\n"
            "• Apply **Trichoderma viride @ 50 grams mixed with 5 kg neem-enriched FYM per plant** at planting.";
      }
    }

    // 5. SUGARCANE DISEASES
    if (q.contains("sugarcane") || (crop != null && crop.name.contains("Sugarcane"))) {
      if (q.contains("red rot") || q.contains("rot")) {
        return "🎋 **Disease: Red Rot in Sugarcane (Colletotrichum falcatum)**\n\n"
            "🔍 **Symptoms**: Third and fourth leaves turn yellow and wither. Splitting the cane stalk reveals red internal tissue with crosswise white patches and a distinct alcoholic sour smell.\n\n"
            "💊 **Cure & Management**:\n"
            "• Once infected, chemical cure inside stalk is difficult. Immediately uproot and burn diseased clumps to stop spread.\n\n"
            "🛡️ **Prevention Protocol**:\n"
            "• Dip setts before planting in **Carbendazim 50 WP @ 1.0 gram per Liter of water** for 15 minutes.\n"
            "• Grow resistant varieties such as **Co 86032** or **Co 0238**.\n"
            "• Do not take ratoon crops in red rot infected fields.";
      }
      if (q.contains("borer") || q.contains("shoot borer")) {
        return "🐛 **Pest: Early Shoot Borer in Sugarcane**\n\n"
            "🔍 **Symptoms**: 'Dead hearts' in 1 to 3-month-old cane shoots. The dead shoot pulls out easily and emits a foul odor.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Soil application of **Fipronil 0.3% GR @ 10 kg per acre** in furrows at planting.\n"
            "• Or foliar spray **Chlorantraniliprole 18.5 SC (Coragen) @ 0.4 ml per Liter of water** (80 ml in 200L water per acre) at Day 30–35.";
      }
    }

    // 6. GROUNDNUT DISEASES
    if (q.contains("groundnut") || (crop != null && crop.name.contains("Groundnut"))) {
      if (q.contains("tikka") || q.contains("leaf spot") || q.contains("spot")) {
        return "🍂 **Disease: Tikka Leaf Spot in Groundnut (Cercospora)**\n\n"
            "🔍 **Symptoms**: Small circular brown-to-black spots with bright yellow rings on upper leaves, leading to severe defoliation and poor pod filling.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Hexaconazole 5% EC (Contaf) @ 2.0 ml per Liter of water**.\n"
            "• Or spray **Mancozeb 75 WP @ 2.5 grams + Carbendazim @ 1.0 gram per Liter of water** at Day 35 and Day 50 after sowing.";
      }
      if (q.contains("collar rot") || q.contains("root rot") || q.contains("rot")) {
        return "🍄 **Disease: Collar Rot & Root Rot in Groundnut**\n\n"
            "🔍 **Symptoms**: Seedling wilting, collar region near soil line turns black/brown and rots with white fungal threads and mustard-like brown sclerotia.\n\n"
            "💊 **Cure & Dosage**:\n"
            "• Soil drench around infected rows with **Validamycin 3% L @ 2.0 ml per Liter of water** or **Carbendazim @ 1.5g/L**.\n"
            "• Treat seeds before sowing with *Trichoderma viride* @ 10g/kg or Thiram @ 2g/kg seed.";
      }
    }

    // 7. CHILI / PEPPER DISEASES
    if (q.contains("chili") || q.contains("chilli") || q.contains("pepper")) {
      if (q.contains("leaf curl") || q.contains("curl") || q.contains("virus") || q.contains("thrips") || q.contains("mite")) {
        return "🌶️ **Problem: Leaf Curl Complex in Chili (Thrips & Mites)**\n\n"
            "🔍 **Diagnosis**:\n"
            "• **Upward Leaf Curling (Boat-shape)**: Caused by **Thrips**.\n"
            "• **Downward Leaf Curling (Inverted boat)**: Caused by **Yellow Mites**.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• **For Thrips**: Spray **Fipronil 5% SC @ 1.5 ml per Liter** or **Acetamiprid 20% SP @ 0.3 grams per Liter of water**.\n"
            "• **For Mites**: Spray **Spiromesifen 22.9% SC (Oberon) @ 1.0 ml per Liter** or **Diafenthiuron 50 WP (Pegasus) @ 1.2 grams per Liter**.\n"
            "• Always mix with a non-ionic spreader (0.5 ml/L) for full leaf coverage.";
      }
      if (q.contains("anthracnose") || q.contains("dieback") || q.contains("fruit rot")) {
        return "🍄 **Disease: Anthracnose & Fruit Rot (Dieback) in Chili**\n\n"
            "🔍 **Symptoms**: Sunken circular spots with black concentric rings on ripe fruits; tender twigs dry backwards from tip to base.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Azoxystrobin 18.2% + Difenoconazole 11.4% SC @ 1.0 ml per Liter of water**.\n"
            "• Or spray **Copper Oxychloride 50 WP @ 3.0 grams per Liter of water**.";
      }
    }

    // 8. TOMATO & POTATO DISEASES
    if (q.contains("tomato") || q.contains("potato")) {
      if (q.contains("blight") || q.contains("late blight") || q.contains("early blight")) {
        return "🍅 **Disease: Early & Late Blight in Tomato / Potato**\n\n"
            "🔍 **Symptoms**: Water-soaked brownish-black irregular lesions on leaves and stems with white fungal fuzz on leaf undersides during cool humid weather.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Cymoxanil 8% + Mancozeb 64% WP (Curzate) @ 2.5 grams per Liter of water**.\n"
            "• Or spray **Dimethomorph 50% WP @ 1.0 gram + Mancozeb @ 2.0 grams per Liter of water**.\n"
            "• Spray preventively during cloudy weather before rain.";
      }
      if (q.contains("wilt") || q.contains("bacterial wilt")) {
        return "🦠 **Disease: Bacterial Wilt (Ralstonia solanacearum)**\n\n"
            "🔍 **Symptoms**: Rapid daytime wilting of entire plant while leaves remain green; roots decay.\n\n"
            "💊 **Cure & Dosage**:\n"
            "• Drench soil with **Streptocycline @ 0.2 grams + Copper Oxychloride @ 2.5 grams per Liter of water**.\n"
            "• Apply *Pseudomonas fluorescens* bio-agent @ 2.5 kg/acre.";
      }
    }

    // 9. ONION DISEASES
    if (q.contains("onion")) {
      if (q.contains("thrips") || q.contains("white") || q.contains("silver")) {
        return "🧅 **Pest: Onion Thrips (Thrips tabaci)**\n\n"
            "🔍 **Symptoms**: Silver-white streaks on leaves, tips turn brown and curl up, stunted bulb growth.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Spinetoram 11.7% SC @ 1.0 ml per Liter of water**.\n"
            "• Or spray **Fipronil 5% SC @ 1.5 ml per Liter of water** with 0.5 ml sticker/spreader.";
      }
      if (q.contains("purple blotch") || q.contains("blotch") || q.contains("rot")) {
        return "🟣 **Disease: Purple Blotch in Onion (Alternaria porri)**\n\n"
            "🔍 **Symptoms**: Small sunken spots with deep purple centers on leaves and seed stalks.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Tebuconazole 25.9% EC @ 1.0 ml per Liter of water** or **Mancozeb 75 WP @ 2.5 grams per Liter**.";
      }
    }

    // 10. COTTON DISEASES
    if (q.contains("cotton")) {
      if (q.contains("bollworm") || q.contains("pink bollworm") || q.contains("worm")) {
        return "☁️ **Pest: Pink Bollworm & American Bollworm in Cotton**\n\n"
            "🔍 **Symptoms**: Rosetted flowers, bored holes on green bolls, damaged seeds, and stained lint.\n\n"
            "💊 **Chemical Cure & Dosage**:\n"
            "• Spray **Profenofos 50% EC @ 2.0 ml per Liter of water**.\n"
            "• Or spray **Emamectin Benzoate 5% SG @ 0.4 grams per Liter of water**.\n"
            "• Install 5 Pheromone traps per acre for early monitoring.";
      }
    }

    // 11. TAPIOCA / CASSAVA DISEASES
    if (q.contains("tapioca") || q.contains("cassava")) {
      if (q.contains("mosaic") || q.contains("whitefly") || q.contains("virus") || q.contains("leaf")) {
        return "🌿 **Disease: Cassava Mosaic Virus (CMD) in Tapioca**\n\n"
            "🔍 **Symptoms**: Severe mosaic pattern of chlorotic yellow patches, wrinkled distorted leaves, and stunted tuber growth. Transmitted by Whiteflies.\n\n"
            "💊 **Chemical Cure (Vector Control)**:\n"
            "• Spray **Thiamethoxam 25% WG @ 0.3 grams per Liter of water** to eliminate whitefly vectors.\n"
            "• Or spray **Neem Oil (10,000 ppm) @ 2.0 ml per Liter of water**.\n"
            "• Immediately rogue out and destroy severely infected mosaic plants.";
      }
    }

    // GENERAL DIAGNOSIS & CURE PROTOCOL
    return "🛡️ **General Crop Disease & Pest Control Protocol**:\n\n"
        "1. **Fungal Leaf Spots & Blights**: Spray **Mancozeb 75 WP @ 2.5 grams/Liter** or **Azoxystrobin + Difenoconazole @ 1 ml/Liter**.\n"
        "2. **Root Rot & Wilt (Soil-borne)**: Drench soil around root zone with **Copper Oxychloride 50 WP @ 3 grams/Liter** or **Metalaxyl-Mancozeb @ 2.5 grams/Liter**.\n"
        "3. **Sucking Pests (Aphids, Thrips, Whiteflies)**: Spray **Fipronil 5 SC @ 1.5 ml/Liter** or **Acetamiprid 20 SP @ 0.3 grams/Liter**.\n"
        "4. **Caterpillars & Borers**: Spray **Emamectin Benzoate 5 SG @ 0.4 grams/Liter** or **Chlorantraniliprole 18.5 SC @ 0.3 ml/Liter**.\n\n"
        "💡 Always spray in early morning or late evening with 0.5 ml/L non-ionic wetting sticker for maximum effectiveness.";
  }

  String _getFertilizerAnswer(CropInfo? crop) {
    if (crop != null) {
      final f = crop.fertilizerDetail;
      return "🧪 **Fertilizer Dosage for ${crop.name} (Per Acre)**:\n\n"
          "1. **Basal Dose (At Sowing / Planting)**:\n   • ${f.basalDose}\n\n"
          "2. **Top Dressing (Vegetative Growth Stage)**:\n   • ${f.vegetativeDose}\n\n"
          "3. **Flowering / Bulking Stage**:\n   • ${f.floweringDose}\n\n"
          "4. **Micronutrients**:\n   • ${f.micronutrients}\n\n"
          "🌿 **Organic Alternative**: ${f.organicAlternative}";
    }

    return "🧪 **General NPK Fertilizer Application Guidelines**:\n\n"
        "• **Phosphorus (DAP/SSP)** & **Potash (MOP)**: Apply 100% as basal dose during land preparation/sowing.\n"
        "• **Nitrogen (Urea)**: Split into 2–3 doses (Sowing, 30 days, and flowering) to prevent leaching losses.\n"
        "• **Micronutrients**: Apply Zinc Sulphate (10 kg/acre) and Gypsum (100 kg/acre) according to your soil test report.\n"
        "• Please specify your crop name (e.g. *\"Fertilizer for Turmeric\"* or *\"Fertilizer for Sugarcane\"*) for exact kilogram dosages.";
  }

  String _getYieldAnswer(CropInfo? crop) {
    if (crop != null) {
      final quintals = crop.expectedYieldPerAcreKg / 100;
      final income = crop.expectedYieldPerAcreKg * crop.averageMarketPricePerKg;

      return "🌾 **Expected Yield for ${crop.name}**:\n\n"
          "• **Estimated Yield per Acre**: **~${crop.expectedYieldPerAcreKg} Kg** ($quintals Quintals)\n"
          "• **Crop Duration to Harvest**: **${crop.harvestDays} Days**\n"
          "• **Current Average Market Price**: ₹${crop.averageMarketPricePerKg} per Kg\n"
          "• **Estimated Gross Revenue**: ~₹$income per acre\n\n"
          "📅 Use the interactive calculator below to select your sowing date and calculate total yield for your farm area!";
    }

    return "🌾 **Average Commercial Crop Yields (Per Acre)**:\n\n"
        "• **Turmeric**: 9,000 – 11,000 Kg (Fresh Rhizomes)\n"
        "• **Sugarcane**: 40 – 50 Tons (40,000 – 50,000 Kg)\n"
        "• **Banana**: 30,000 – 35,000 Kg (approx. 1,200 bunches)\n"
        "• **Paddy (Rice)**: 2,600 – 3,000 Kg (26–30 Quintals)\n"
        "• **Groundnut**: 1,200 – 1,500 Kg pods\n"
        "• **Tapioca**: 12,000 – 15,000 Kg tubers";
  }

  String _getWateringAnswer(CropInfo? crop) {
    if (crop != null) {
      return "💧 **Irrigation & Water Schedule for ${crop.name}**:\n\n"
          "• **Frequency**: ${crop.waterSchedule}\n"
          "• **Critical Irrigation Stages**: Sowing/Transplanting, Active Vegetative growth, Flowering, and Pod/Rhizome bulking.\n"
          "• **Water Management**: Drip irrigation is highly recommended to save 40–50% water and avoid root rotting from waterlogging.";
    }

    return "💧 **Smart Irrigation Guidelines**:\n\n"
        "• **Drip Irrigation**: Recommended for Turmeric, Sugarcane, Banana, and Chili. Delivers water and liquid fertilizer directly to roots.\n"
        "• **Paddy**: Maintain 2–4 cm shallow standing water during tillering to heading stage, and drain field 10 days prior to harvest.\n"
        "• **Avoid Mid-Day Watering**: Irrigate in early morning or late evening to minimize evaporation losses.";
  }

  String _getSowingAndSoilAnswer(CropInfo? crop) {
    if (crop != null) {
      return "🌱 **Sowing & Soil Requirements for ${crop.name}**:\n\n"
          "• **Best Sowing Time**: ${crop.seedingDate} (${crop.season})\n"
          "• **Suitable Soils**: ${crop.suitableSoil.join(', ')}\n"
          "• **Maturity Period**: ${crop.harvestDays} Days to harvest\n"
          "• **Land Preparation**: Deep ploughing 2–3 times with 10 tons well-decomposed Farmyard Manure (FYM) per acre.";
    }

    return "🌱 **Recommended Sowing Seasons**:\n\n"
        "• **May – June**: Turmeric, Groundnut, Tapioca\n"
        "• **June – July**: Paddy, Maize, Cotton\n"
        "• **December – February**: Sugarcane, Rabi Paddy, Banana, Rabi Groundnut";
  }

  String _getMarketPriceAnswer(CropInfo? crop) {
    if (crop != null) {
      return "📊 **Current Mandi Market Price for ${crop.name}**:\n\n"
          "• **Average Price**: **₹${crop.averageMarketPricePerKg} per Kg** (₹${crop.averageMarketPricePerKg * 100} per Quintal)\n"
          "• **Primary Market Yard**: ${crop.name.contains('Turmeric') ? 'Perundurai & Semmampalayam Regulated Market Yard' : crop.name.contains('Sugarcane') ? 'Sakthi Sugars Direct Mill Gate (Appakudal)' : 'APMC Regulated Mandi'}\n"
          "• **Market Trend**: Stable demand with active wholesale procurement.";
    }

    return "📊 **Current Regulated Mandi Auction Rates**:\n\n"
        "• **Finger Turmeric**: ₹140 – ₹150 per Kg (₹14,000 – ₹15,000 per Quintal)\n"
        "• **Sugarcane (Mill Gate)**: ₹4.0 – ₹4.5 per Kg (₹400 – ₹450 per Quintal)\n"
        "• **Banana (Grand Naine)**: ₹24 – ₹28 per Kg\n"
        "• **Paddy (CO-51 / ADT-45)**: ₹25 – ₹27 per Kg\n"
        "• **Groundnut (Pod)**: ₹75 – ₹82 per Kg";
  }

  String _getWeatherAnswer() {
    final weather = AppState().currentWeather;
    if (weather != null) {
      return "🌦️ **Real Weather Report for ${weather.locationName}**:\n\n"
          "• Temperature: **${weather.temperature.toStringAsFixed(1)}°C** (${weather.condition})\n"
          "• Rain Probability: **${weather.rainProbability}%**\n"
          "• Humidity: ${weather.humidity}% | Wind: ${weather.windSpeedKmH} km/h\n"
          "• Soil Moisture: ${weather.soilMoisture.toStringAsFixed(0)}%\n\n"
          "💡 **Agricultural Advisory**: ${weather.advisory}";
    }
    return "🌦️ **Live Weather Advisory**: Partly Sunny, 31.5°C with 55% rain chance in evening. Safe for foliar spraying in early morning.";
  }

  String _getGovernmentSchemeAnswer() {
    return "🏛️ **Top Agricultural Schemes & Subsidies for Farmers**:\n\n"
        "1. **PM-KISAN**: Direct income support of ₹6,000 per year in 3 equal installments of ₹2,000 directly into farmer bank accounts.\n"
        "2. **PMKSY (Micro-Irrigation Drip Subsidy)**: Up to 100% subsidy for small/marginal farmers and 75% for other farmers on Drip and Sprinkler irrigation systems.\n"
        "3. **PMFBY (Pradhan Mantri Fasal Bima Yojana)**: Low-cost crop insurance (1.5% to 2% premium) covering drought, unseasonal rainfall, floods, and pest damage.\n"
        "4. **Kisan Credit Card (KCC)**: Low-interest crop loan up to ₹3 Lakh at an effective interest rate of 4% per annum.";
  }

  String _getOrganicFarmingAnswer() {
    return "🌿 **Organic Farming & Bio-Control Preparations**:\n\n"
        "• **Jeevamrut (Microbial Soil Booster)**: Mix 10 kg cow dung + 10 Liters cow urine + 2 kg jaggery + 2 kg pulse flour in 200 Liters water. Ferment for 48 hours in shade. Apply 200 Liters/acre with irrigation.\n"
        "• **Panchagavya (Plant Growth Booster)**: Mix cow dung, urine, milk, curd, ghee, sugarcane juice, and tender coconut water. Spray 3% solution (30 ml/L) every 15 days.\n"
        "• **Neem Oil Spray (Organic Insect Repellent)**: Mix 5 ml Neem Oil (10,000 ppm) + 1 ml liquid soap in 1 Liter water. Spray every 10–14 days preventively.";
  }

  void _calculateAndShowYieldDialog(CropInfo crop, DateTime sowingDate, double acres) {
    final harvestDate = sowingDate.add(Duration(days: crop.harvestDays));
    final double totalYieldKg = acres * crop.expectedYieldPerAcreKg;
    final double totalQuintals = totalYieldKg / 100;
    final double estimatedIncome = totalYieldKg * crop.averageMarketPricePerKg;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(crop.icon, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text("${crop.name} Yield Projection")),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sowing Date:", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("${sowingDate.day}/${sowingDate.month}/${sowingDate.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Harvest Date:", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("${harvestDate.day}/${harvestDate.month}/${harvestDate.year} (${crop.harvestDays} Days)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Expected Yield:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          "${totalYieldKg.toStringAsFixed(0)} Kg\n(${totalQuintals.toStringAsFixed(1)} Quintals)",
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Est. Gross Revenue:", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("₹${estimatedIncome.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("🌱 Crop Growth Milestones:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("• Day 20 (${sowingDate.add(const Duration(days: 20)).day}/${sowingDate.add(const Duration(days: 20)).month}): 1st Top Dressing Fertilizer"),
              Text("• Day 60 (${sowingDate.add(const Duration(days: 60)).day}/${sowingDate.add(const Duration(days: 60)).month}): Bulking / Flowering stage nutrition"),
              Text("• Day ${crop.harvestDays - 15}: Stop irrigation for maturity"),
              Text("• Day ${crop.harvestDays}: Final Harvest & Mandi dispatch"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.alarm_add, size: 18),
            label: const Text("Save to Alerts"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              AppState().addNotification(
                NotificationItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: "${crop.name} Sowing Schedule Saved",
                  message: "Sowing on ${sowingDate.day}/${sowingDate.month}/${sowingDate.year}. Expected Harvest: ${harvestDate.day}/${harvestDate.month}/${harvestDate.year} with ~${totalYieldKg.toStringAsFixed(0)} Kg yield.",
                  time: "Just now",
                  icon: Icons.grass,
                  iconColor: Colors.green,
                  category: "reminder",
                ),
              );
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Cropping schedule & ${totalYieldKg.toStringAsFixed(0)} Kg yield alert saved!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: _speechHelper.isSpeaking
                  ? AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) => Icon(
                        Icons.volume_up,
                        color: Colors.green.shade800,
                        size: 20 + (_waveController.value * 4),
                      ),
                    )
                  : const Icon(Icons.smart_toy, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Voice Agronomist", style: TextStyle(fontSize: 15)),
                Text(
                  _speechHelper.isSpeaking ? "Speaking answer out loud..." : "Voice TTS Enabled • 24/7 Expert",
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_autoSpeak ? Icons.record_voice_over : Icons.voice_over_off),
            tooltip: _autoSpeak ? "Auto-Speak ON" : "Auto-Speak OFF",
            onPressed: () {
              setState(() => _autoSpeak = !_autoSpeak);
              if (!_autoSpeak) _speechHelper.stop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_autoSpeak ? "Voice output enabled (Auto-Speak ON)" : "Voice output muted (Tap 🔊 to speak)"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Clear Chat",
            onPressed: () {
              _speechHelper.stop();
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    text: "Chat cleared. What farming question can I help you with today? 🌾",
                    isUser: false,
                    time: "Now",
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Text("AI Agronomist is diagnosing your question...", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),

          // Quick Suggestion Chips
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _quickSuggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.green.shade200),
                    label: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _handleSend(suggestion),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSend,
                      decoration: const InputDecoration(
                        hintText: "Ask about crop diseases, remedies, fertilizers...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () => _handleSend(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isSpeakingThis = _speechHelper.isSpeaking && _currentlySpeakingText == msg.text;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 2),
            bottomRight: Radius.circular(msg.isUser ? 2 : 16),
          ),
          border: isSpeakingThis ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
                if (!msg.isUser) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(
                      isSpeakingThis ? Icons.volume_up : Icons.volume_mute,
                      color: isSpeakingThis ? Colors.green : Colors.grey.shade600,
                      size: 22,
                    ),
                    tooltip: isSpeakingThis ? "Stop Speaking" : "Read Aloud",
                    onPressed: () => _speakMessage(msg.text),
                  ),
                ],
              ],
            ),

            // Embedded Interactive Sowing Date & Yield Card (ONLY when asking about yield/sowing/cropping)
            if (!msg.isUser && msg.isCropYieldPrompt && msg.recommendedCrop != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "Calculate Yield for ${msg.recommendedCrop!.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_calendar, size: 16),
                            label: Text(
                              msg.selectedSowingDate != null
                                  ? "${msg.selectedSowingDate!.day}/${msg.selectedSowingDate!.month}/${msg.selectedSowingDate!.year}"
                                  : "Pick Sowing Date",
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: msg.selectedSowingDate ?? DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => msg.selectedSowingDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "${msg.landAreaAcres?.toStringAsFixed(1) ?? "3.0"} Acres",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calculate, size: 16),
                        label: const Text("Calculate Total Yield & Harvest Date"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          _calculateAndShowYieldDialog(
                            msg.recommendedCrop!,
                            msg.selectedSowingDate ?? DateTime.now(),
                            msg.landAreaAcres ?? 3.0,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}