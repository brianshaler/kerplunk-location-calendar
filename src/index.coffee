
module.exports = (System) ->

  calendar = (req, res, next) ->
    res.render 'history',
      title: 'Calendar'

  globals:
    public:
      nav:
        Visualize:
          Calendar: '/admin/visualize/calendar'
      css:
        'kerplunk-location-calendar:history': 'kerplunk-location-calendar/css/calendar.css'
        'kerplunk-location-calendar:calendar': 'kerplunk-location-calendar/css/calendar.css'
        'kerplunk-location-calendar:summary': 'kerplunk-location-calendar/css/calendar.css'
      requirejs:
        paths:
          moment: '/plugins/kerplunk-location-calendar/js/moment.min.js'
          'spark-md5': '/plugins/kerplunk-location-calendar/js/spark-md5.min.js'

  routes:
    admin:
      '/admin/visualize/calendar': 'calendar'
    public:
      '/visualize/calendar': 'calendar'

  handlers:
    calendar: calendar
