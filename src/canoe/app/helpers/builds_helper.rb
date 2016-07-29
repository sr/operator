module BuildsHelper
  def streetlight_locals(build, test)
    key = (test == :PPANT) ? "passedCI" : "ciJob[#{test}]"
    state = build.options[:meta_data][key]
    build_time = DateTime.parse(build.options[:meta_data]["buildTimeStamp"]).iso8601

    # Since Bamboo doesn't have a run code on failure option we don't know if
    # the build plan is still processing
    # TODO: Interface with the Bamboo API to verify build status
    if state == "false" && build_time > 30.minutes.ago
      state = "pending"
    end

    {
      state: state,
      build_url: build.options[:meta_data]["ciJobUrl[#{test}]"]
    }
  end
end
