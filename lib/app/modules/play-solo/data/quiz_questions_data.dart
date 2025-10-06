import '../models/quiz_question_model.dart';

class QuizQuestionsData {
  static List<QuizQuestionModel> getQuestions() {
    return [
      QuizQuestionModel(
        id: 'q1',
        question: 'What is the correct form of the verb "to be" in the present tense for "he"?',
        options: ['am', 'is', 'are', 'be'],
        correctAnswerIndex: 1,
        explanation: 'The correct form is "is" for third person singular (he, she, it).',
        difficulty: 'Beginner',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q2',
        question: 'Which sentence is grammatically correct?',
        options: [
          'I have went to the store',
          'I have gone to the store',
          'I have go to the store',
          'I have going to the store'
        ],
        correctAnswerIndex: 1,
        explanation: 'The present perfect tense uses "have/has + past participle". "Gone" is the past participle of "go".',
        difficulty: 'Intermediate',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q3',
        question: 'What does the word "ubiquitous" mean?',
        options: ['Rare', 'Present everywhere', 'Expensive', 'Difficult'],
        correctAnswerIndex: 1,
        explanation: 'Ubiquitous means present, appearing, or found everywhere.',
        difficulty: 'Advanced',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q4',
        question: 'Which of the following is a synonym for "happy"?',
        options: ['Sad', 'Joyful', 'Angry', 'Tired'],
        correctAnswerIndex: 1,
        explanation: 'Joyful is a synonym for happy, meaning feeling or showing great pleasure.',
        difficulty: 'Beginner',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q5',
        question: 'What is the plural form of "child"?',
        options: ['childs', 'children', 'childes', 'child'],
        correctAnswerIndex: 1,
        explanation: 'The plural form of "child" is "children", which is an irregular plural.',
        difficulty: 'Beginner',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q6',
        question: 'Which sentence uses the correct conditional form?',
        options: [
          'If I will have time, I will call you',
          'If I have time, I will call you',
          'If I had time, I will call you',
          'If I have time, I would call you'
        ],
        correctAnswerIndex: 1,
        explanation: 'First conditional uses "if + present simple, will + infinitive".',
        difficulty: 'Intermediate',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q7',
        question: 'What does "procrastinate" mean?',
        options: ['To work quickly', 'To delay or postpone', 'To celebrate', 'To communicate'],
        correctAnswerIndex: 1,
        explanation: 'To procrastinate means to delay or postpone action; to put off doing something.',
        difficulty: 'Advanced',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q8',
        question: 'Which word is the antonym of "generous"?',
        options: ['Kind', 'Stingy', 'Helpful', 'Friendly'],
        correctAnswerIndex: 1,
        explanation: 'Stingy is the antonym of generous, meaning unwilling to give or spend.',
        difficulty: 'Intermediate',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q9',
        question: 'What is the correct passive voice form of "They built the house"?',
        options: [
          'The house was built by them',
          'The house is built by them',
          'The house has built by them',
          'The house will built by them'
        ],
        correctAnswerIndex: 0,
        explanation: 'The passive voice uses "was/were + past participle" for past tense.',
        difficulty: 'Intermediate',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q10',
        question: 'Which of the following is an example of a metaphor?',
        options: [
          'The wind howled like a wolf',
          'Time is money',
          'She is as tall as a tree',
          'The car roared down the street'
        ],
        correctAnswerIndex: 1,
        explanation: 'A metaphor directly compares two things without using "like" or "as".',
        difficulty: 'Advanced',
        topic: 'Literature',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q11',
        question: 'What is the correct form of the adjective "good" in the comparative degree?',
        options: ['gooder', 'better', 'more good', 'goodest'],
        correctAnswerIndex: 1,
        explanation: 'The comparative form of "good" is "better", which is irregular.',
        difficulty: 'Beginner',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q12',
        question: 'Which sentence contains a gerund?',
        options: [
          'I am running in the park',
          'Running is good exercise',
          'I run every morning',
          'The running water is cold'
        ],
        correctAnswerIndex: 1,
        explanation: 'A gerund is a verb form ending in -ing that functions as a noun.',
        difficulty: 'Intermediate',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q13',
        question: 'What does "ephemeral" mean?',
        options: ['Lasting forever', 'Lasting for a very short time', 'Very large', 'Very small'],
        correctAnswerIndex: 1,
        explanation: 'Ephemeral means lasting for a very short time; transitory.',
        difficulty: 'Advanced',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q14',
        question: 'Which of the following is a compound sentence?',
        options: [
          'The cat sat on the mat',
          'The cat sat on the mat, and the dog slept nearby',
          'Sitting on the mat, the cat purred',
          'The cat, which was black, sat on the mat'
        ],
        correctAnswerIndex: 1,
        explanation: 'A compound sentence contains two or more independent clauses joined by a conjunction.',
        difficulty: 'Intermediate',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q15',
        question: 'What is the meaning of "serendipity"?',
        options: [
          'Bad luck',
          'The occurrence of events by chance in a happy way',
          'Hard work',
          'Intelligence'
        ],
        correctAnswerIndex: 1,
        explanation: 'Serendipity is the occurrence of events by chance in a happy or beneficial way.',
        difficulty: 'Advanced',
        topic: 'Vocabulary',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q16',
        question: 'Which word is the correct spelling?',
        options: ['Accomodate', 'Accommodate', 'Acommodate', 'Accomadate'],
        correctAnswerIndex: 1,
        explanation: 'Accommodate is spelled with double m and double c.',
        difficulty: 'Intermediate',
        topic: 'Spelling',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q17',
        question: 'What is the correct preposition to use with "depend"?',
        options: ['depend in', 'depend on', 'depend at', 'depend for'],
        correctAnswerIndex: 1,
        explanation: 'The correct preposition with "depend" is "on" (depend on).',
        difficulty: 'Beginner',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q18',
        question: 'Which of the following is an example of alliteration?',
        options: [
          'The sun shines brightly',
          'Peter Piper picked a peck of pickled peppers',
          'The cat in the hat',
          'She sells seashells by the seashore'
        ],
        correctAnswerIndex: 1,
        explanation: 'Alliteration is the repetition of the same sound at the beginning of words.',
        difficulty: 'Advanced',
        topic: 'Literature',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q19',
        question: 'What is the correct form of the verb "to lie" (meaning to recline) in the past tense?',
        options: ['lied', 'lay', 'lain', 'lying'],
        correctAnswerIndex: 1,
        explanation: 'The past tense of "lie" (to recline) is "lay".',
        difficulty: 'Advanced',
        topic: 'Grammar',
        timeLimit: 30,
      ),
      QuizQuestionModel(
        id: 'q20',
        question: 'Which sentence is in the subjunctive mood?',
        options: [
          'I wish I was taller',
          'I wish I were taller',
          'I wish I am taller',
          'I wish I will be taller'
        ],
        correctAnswerIndex: 1,
        explanation: 'The subjunctive mood uses "were" instead of "was" for hypothetical situations.',
        difficulty: 'Advanced',
        topic: 'Grammar',
        timeLimit: 30,
      ),
    ];
  }

  static List<QuizQuestionModel> getQuestionsForDifficulty(String difficulty) {
    return getQuestions().where((q) => q.difficulty == difficulty).toList();
  }

  static List<QuizQuestionModel> getQuestionsForTopic(String topic) {
    return getQuestions().where((q) => q.topic == topic).toList();
  }

  static List<QuizQuestionModel> getRandomQuestions(int count) {
    final allQuestions = getQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
}
