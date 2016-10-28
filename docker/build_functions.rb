def full_base_image_url(tag, mirror = nil)
  "#{mirror || DOCKER_HOST}/base/#{tag}"
end

def docker_build(tag, directory, opts = {})
  image_url = full_base_image_url(tag)

  if File.exist?("#{directory}/Rakefile")
    # Build has its own Rakefile for custom build steps
    Dir.chdir(directory) do
      sh "rake", "DOCKER_IMAGE_URL=#{image_url}", "ARTIFACTORY_HOST=#{ARTIFACTORY_HOST}"
    end
  elsif File.exist?("#{directory}/Makefile")
    # Build has its own Makefile for custom build steps
    Dir.chdir(directory) do
      sh "make", "DOCKER_IMAGE_URL=#{image_url}", "ARTIFACTORY_HOST=#{ARTIFACTORY_HOST}"
    end
  else
    # Standard `docker build`
    pull = opts.fetch(:pull, false)
    sh *[
      "docker",
      "build",
      pull ? "--pull" : nil,
      "--build-arg", "artifactory_host=#{ARTIFACTORY_HOST}",
      "-t", image_url,
      directory
    ].compact
  end

  docker_push(tag) if PUSH
end

def docker_push(tag)
  sh "docker", "push", full_base_image_url(tag)
end

def docker_pull(tag, mirror = nil)
  sh "docker", "pull", full_base_image_url(tag, mirror)
  sh "docker", "tag", full_base_image_url(tag, mirror), full_base_image_url(tag)
end
