require "active_support/all"

class ExerciseHandler < ApplicationHandler
  route(/^exercise time$/i, :exercise_time, command: false, help: { "exercise_time" => "returns a random exercise and a time-based intensity" })

  def exercise_time(request)
    exercise = exercises[rand(0..exercises.length - 1)]
    current_hour = Time.current.hour
    intensity = case exercise[:function]
                when :reps
                  reps current_hour
                when :time
                  time current_hour
                else
                  "ERROR with reps"
                end
    request.reply "#{exercise[:phrase]} #{intensity}"
  end

  def exercises
    [
      { phrase: "Drop and give me", function: :reps },
      { phrase: "Plank! Hold it for", function: :time },
      { phrase: "Squats! Give me", function: :reps },
      { phrase: "Lunges! Give me", function: :reps }
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
