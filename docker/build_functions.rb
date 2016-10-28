def full_image_url(tag)
  "#{DOCKER_BASE_IMAGE_PATH}/#{tag}"
end

def docker_build(tag, directory, opts = {})
  image_url = full_image_url(tag)

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

  docker_push(image_url) if PUSH
end

def docker_push(image_url)
  sh "docker", "push", image_url
end

def docker_pull(image_url)
  sh "docker", "pull", image_url
end
