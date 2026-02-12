import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/gemini_service.dart';
import 'city_tour_view_model.dart';
import '../../domain/entities/city.dart';

class ChatState {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;

  ChatState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

class ChatViewModel extends StateNotifier<ChatState> {
  final GeminiService _geminiService;
  final CityTourViewModel _cityTourViewModel;

  ChatViewModel(this._geminiService, this._cityTourViewModel) : super(ChatState());

  Future<void> sendMessage(String query) async {
    print('ChatViewModel: sendMessage called with query: "$query"');
    if (query.trim().isEmpty) {
      print('ChatViewModel: Query is empty, returning.');
      return;
    }

    // 1. Add User Message
    final userMsg = ChatMessage(text: query, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );
    print('ChatViewModel: User message added, state updated to loading.');

    try {
      // 2. Call Gemini
      print('ChatViewModel: Calling _geminiService.getPlaces...');
      final places = await _geminiService.getPlaces(query);
      print('ChatViewModel: _geminiService.getPlaces returned ${places.length} places.');

      // 3. Add AI Message
      final aiMsg = ChatMessage(
        text: 'I found ${places.length} amazing places for you. Starting the tour on Liquid Galaxy!',
        isUser: false,
      );
      
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
      print('ChatViewModel: AI message added, state updated to not loading.');

      // 4. Start Tour
      print('ChatViewModel: Calling _cityTourViewModel.startTour...');
      await _cityTourViewModel.startTour(customCities: places);
      print('ChatViewModel: Tour started.');

    } catch (e, stackTrace) {
      print('ChatViewModel: Error in sendMessage: $e');
      print('ChatViewModel: Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: "Failed to fetch recommendations. Please try again.",
        messages: [...state.messages, ChatMessage(text: "Sorry, something went wrong: $e", isUser: false)],
      );
    }
  }
  
  void clearMessages() {
    state = ChatState();
  }

  void stopTour() {
    _cityTourViewModel.stopTour();
  }
}

final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final geminiService = ref.read(geminiServiceProvider);
  final cityTourViewModel = ref.read(cityTourProvider.notifier);
  return ChatViewModel(geminiService, cityTourViewModel);
});
