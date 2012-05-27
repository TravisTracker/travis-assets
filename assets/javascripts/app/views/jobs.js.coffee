@Travis.Views = {} if @Travis.Views == undefined

@Travis.Views.Jobs =
  List: Ember.View.extend
    templateName: 'app/templates/jobs/list'
    controllerBinding: 'Travis.app.main'
    buildBinding: 'controller.build'

    # jobs: (->
    #   build = @get('build')
    #   console.log build.getPath('data.job_ids') if build
    #   Travis.Job.forBuild(build) if build
    # ).property('build.data.job_ids')

    # isMatrix: (->
    #   @getPath('build.data.job_ids.length') > 1
    # ).property('build.data.job_ids.length')

    # hasFailureMatrix: (->
    #   @get('allowedFailureJobs').length > 0
    # ).property('allowedFailureJobs')

    # jobs: (->
    #   @getPath('build.jobs')
    # ).property('build.jobs.length')

    # requiredJobs: (->
    #   @get('jobs').filter (item, index) -> item.get('allow_failure') isnt true
    # ).property('jobs')

    # allowedFailureJobs: (->
    #   @get('jobs').filter (item, index) -> item.get 'allow_failure'
    # ).property('jobs')

    configKeys: (->
      config = @getPath('build.config')
      return [] unless config
      keys = $.keys($.only(config, 'rvm', 'gemfile', 'env', 'otp_release', 'php', 'node_js', 'perl', 'python', 'scala'))
      headers = [I18n.t('build.job'), I18n.t('build.duration'), I18n.t('build.finished_at')]
      $.map(headers.concat(keys), (key) -> return $.camelize(key))
    ).property('build.config')

  Item: Ember.View.extend
    tagName: 'tbody'

    repository: (->
      @getPath('content.repository')
    ).property('content.repository')

    color: (->
      Travis.Helpers.colorForResult(this.getPath('content.result'))
    ).property('content.result')

    configValues: (->
      config = @getPath('content.config')
      return [] unless config
      values = $.values($.only(config, 'rvm', 'gemfile', 'env', 'otp_release', 'php', 'node_js', 'scala', 'jdk', 'python', 'perl'))
      $.map(values, (value) -> Ember.Object.create(value: value))
    ).property('content.config')

    urlJob: (->
      repo = @get('repository')
      job = @get('content')
      Travis.Urls.job(repo, job) if repo && job
    ).property('repository', 'content')

  Show: Ember.View.extend
    templateName: 'app/templates/jobs/show'
    controllerBinding: 'Travis.app.main'
    repositoryBinding: 'controller.repository'
    jobBinding: 'controller.job'
    commitBinding: 'controller.job.commit'

    color: (->
      Travis.Helpers.colorForResult(this.getPath('job.result'))
    ).property('job.result')

    urlJob: (->
      repo = @get('repository')
      job = @get('job')
      Travis.Urls.job(repo, job) if repo && job
    ).property('repository', 'job.id')

    urlGithubCommit: (->
      repo = @get('repository')
      commit = @get('commit')
      Travis.Urls.githubCommit(repo, commit) if repo && commit
    ).property('repository', 'commit')

    urlAuthor: (->
      commit = @get('commit')
      Travis.Urls.author(commit) if commit
    ).property('commit')

    urlCommitter: (->
      commit = @get('commit')
      Travis.Urls.committer(commit) if commit
    ).property('commit')

  Log: Ember.View.extend
    templateName: 'app/templates/jobs/log'
    controllerBinding: 'Travis.app.main'
    jobBinding: 'controller.job'

    didInsertElement: ->
      @_super.apply(this, arguments)
      # TODO: FIXME: how/where to do this properly?
      Ember.run.later this, (->
        number = Travis.app.main.getPath('params.number')
        line = $(".log a[name='" + number + "']")
        if (number && line.length > 0)
          $(window).scrollTop(line.offset().top)
          line.addClass('highlight')
      ), 500

