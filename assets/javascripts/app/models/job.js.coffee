@Travis.Job = Travis.Model.extend Travis.Helpers,
  repository_id:   DS.attr('number')
  build_id:        DS.attr('number')
  log_id:          DS.attr('number')
  queue:           DS.attr('string')
  state:           DS.attr('string')
  number:          DS.attr('string')
  result:          DS.attr('number')
  started_at:      DS.attr('string')
  finished_at:     DS.attr('string')
  allow_failure:   DS.attr('boolean')

  repository: DS.belongsTo('Travis.Repository')
  commit: DS.belongsTo('Travis.Commit')
  build: DS.belongsTo('Travis.Build')
  log: DS.belongsTo('Travis.Artifact')

  config: (->
    @getPath 'data.config'
  ).property('data.config')

  duration: (->
    @durationFrom @get('started_at'), @get('finished_at')
  ).property('started_at', 'finished_at')

  sponsor: (->
    @getPath('data.sponsor')
  ).property('data.sponsor')

  appendLog: (log) ->
    @set 'log', @get('log') + log

  subscribe: ->
    Travis.app.subscribe 'job-' + @get('id')

  onStateChange: (->
    Travis.app.unsubscribe 'job-' + @get('id') if @get('state') == 'finished'
  ).observes('state')

  tick: ->
    @notifyPropertyChange 'duration'
    @notifyPropertyChange 'finished_at'

@Travis.Job.reopenClass
  queued: (queue) ->
    @all()
    Travis.app.store.filter this, (job) -> job.get('queue') == 'builds.' + queue
  findMany: (ids) ->
    Travis.app.store.findMany this, ids
