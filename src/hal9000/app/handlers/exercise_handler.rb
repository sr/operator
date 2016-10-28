class ExerciseHandler < ApplicationHandler
  route(/^exercise time$/i, :exercise_time, command: false, help: { "exercise_time" => "returns a random exercise and a time-based intensity" })

  def exercise_time(request)
    exercise = exercises[rand(0..exercises.length)]
    intensity = public_send(exercise[:function], Time.now.getlocal("-05:00").hour)
    request.reply "#{exercise[:phrase]} #{intensity}"
  end

  def exercises
    [
      { phrase: "Drop and give me", function: :reps },
      { phrase: "Plank! Hold it for", function: :time },
      { phrase: "Squats! Give me", function: :reps },
      # { "Pullups! Go to failure or", function: :reps }
    ]
  end

  def reps(current_hour)
    current_hour
  end

  def time(current_hour)
    return 24 if current_hour == 0
    current_hour * 5
  end
end
