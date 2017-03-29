require "active_support/all"

class BeachBodAbsChallenge < ApplicationHandler

  route(/^beachbod$/i, :exercise_time, command: false, help: { "beach_bod_abs_challenge_time" => "returns a random ab exercise and a time-based intensity" })

  def exercise_time(request)
    exercise = exercises[rand(0..exercises.length - 1)]
    request.reply "Beach Bod Ab Challenge: #{exercise[:phrase]} 30 reps. Do it! \n#{exercise[:gif]}"
  end

  def exercises
      [
        { phrase: "Standard Crunches", gif: "http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/929cc1dd-f0fe-49d5-b2b7-18101d48074a.gif" },
        { phrase: "Reverse Crunches", gif: "http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/b6e78136-8792-4288-b0a9-350f94adfe12.gif" },
        { phrase: "Raise Leg Crunches", gif: "http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/a39d823e-f0e5-405c-99ac-07f9c7db0f0a.gif" },
        { phrase: "Frog Crunches", gif: "http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/7a378059-818a-41f7-84bb-034783d9c265.gif" },
        { phrase: "Bicycle Crunches", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/4892ee9f-412e-470f-beaa-ed92e5b7a62d.gif"},
        { phrase: "Side Crunches", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/b9a9e2ed-b7bd-4755-8378-a0e498ae6a68.gif"},
        { phrase: "Full Sit Ups", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/1d878326-f44c-469a-979b-7669ee1b57d1.gif"},
        { phrase: "Wide Leg Sit Ups", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/c85598ce-2953-46f8-8512-662b7b26bd11.gif"},
        { phrase: "Running Man Sit Ups", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/cdb361ef-c6b5-4e4e-897e-4bf09d5a04d8.gif"},
        { phrase: "Reverse Crunch Pulse", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/c8a3ff67-caf2-4e6f-873b-10b8febf9f23.gif"},
        { phrase: "V Ups", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/582765cd-fd20-408c-aec3-8187f3848a2a.gif"},
        { phrase: "Russion Twists", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/d33aaa03-9655-47e3-aa35-e81e0dbbc2b8.gif"},
        { phrase: "Scissor Kicks", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/f776c5d0-1175-44b3-bb2c-147063c73e7e.gif"},
        { phrase: "Side Plank Crunches", gif:"http://img.aws.livestrongcdn.com/ls-slideshow-main-image/cme/photography.prod.demandstudios.com/26d57068-984b-4f13-a4ec-695e31efcbe6.gif"}
      ]
    end
end
