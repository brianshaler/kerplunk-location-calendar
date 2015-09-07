
module.exports = (System) ->

  calendar = (req, res, next) ->
    res.render 'history',
      title: 'Calendar'

  globals:
    public:
      nav:
        Visualize:
          Calendar: '/admin/visualize/calendar'
      styles:
        'kerplunk-location-calendar/css/calendar.css': ['/admin/visualize/calendar']
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
