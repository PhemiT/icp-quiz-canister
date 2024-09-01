import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Float "mo:base/Float";

actor {
  type Question = {
    id : Nat;
    text : Text;
    options : [Text];
    correctAnswer : Nat;
  };

  type Quiz = {
    id : Nat;
    title : Text;
    questions : Buffer.Buffer<Question>;
  };

  type ShareableQuiz = {
    id : Nat;
    title : Text;
    questions : [Question];
  };

  type QuizSubmission = {
    quizId : Nat;
    studentId : Text;
    answers : [Nat];
  };

  var quizzes = Buffer.Buffer<Quiz>(0);
  var submissions = Buffer.Buffer<QuizSubmission>(0);

  public func createQuiz(title : Text) : async Nat {
    let quizId = quizzes.size();
    let newQuiz : Quiz = {
      id = quizId;
      title = title;
      questions = Buffer.Buffer<Question>(0);
    };
    quizzes.add(newQuiz);
    quizId;
  };

  public func addQuestion(quizId : Nat, questionText : Text, options : [Text], correctAnswer : Nat) : async () {
    let quiz = quizzes.get(quizId);
    let questionId = quiz.questions.size();
    let newQuestion : Question = {
      id = questionId;
      text = questionText;
      options = options;
      correctAnswer = correctAnswer;
    };
    quiz.questions.add(newQuestion);
  };

  public query func getQuizDetails(quizId : Nat) : async ShareableQuiz {
    let quiz = quizzes.get(quizId);
    {
      id = quiz.id;
      title = quiz.title;
      questions = Buffer.toArray(quiz.questions);
    };
  };

  public func submitQuiz(quizId : Nat, studentId : Text, answers : [Nat]) : async () {
    let submission : QuizSubmission = {
      quizId = quizId;
      studentId = studentId;
      answers = answers;
    };
    submissions.add(submission);
  };

  public func gradeQuiz(quizId : Nat, studentId : Text) : async Nat {
    let quiz = quizzes.get(quizId);
    var submissionOpt : ?QuizSubmission = null;
    for (s in submissions.vals()) {
      if (s.quizId == quizId and s.studentId == studentId) {
        submissionOpt := ?s;
      };
    };

    switch (submissionOpt) {
      case (null) { return 0 }; // No submission found
      case (?submission) {
        var score = 0;
        for (i in submission.answers.keys()) {
          if (i < quiz.questions.size() and submission.answers[i] == quiz.questions.get(i).correctAnswer) {
            score += 1;
          };
        };
        score;
      };
    };
  };

  public func getQuizStatistics(quizId : Nat) : async {
    totalSubmissions : Nat;
    averageScore : Float;
  } {
    var totalSubmissions = 0;
    var totalScore = 0;

    for (s in submissions.vals()) {
      if (s.quizId == quizId) {
        totalSubmissions += 1;
        totalScore += await gradeQuiz(quizId, s.studentId);
      };
    };

    {
      totalSubmissions = totalSubmissions;
      averageScore = if (totalSubmissions == 0) 0 else Float.fromInt(totalScore) / Float.fromInt(totalSubmissions);
    };
  };
};
