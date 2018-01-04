
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
        'kerplunk-location-calendar:history': [
          'kerplunk-bootstrap/css/bootstrap.css'
          'kerplunk-location-calendar/css/calendar.css'
        ]
        'kerplunk-location-calendar:calendar': 'kerplunk-location-calendar/css/calendar.css'
        'kerplunk-location-calendar:summary': 'kerplunk-location-calendar/css/calendar.css'
      requirejs:
        paths:
          regl: '/plugins/kerplunk-location-calendar/js/regl.min.js'
      blog:
        embedComponent:
          'kerplunk-location-calendar:embedMonth':
            name: 'Travel Calendar'
            description: "show a month of travel"

  routes:
    admin:
      '/admin/visualize/calendar': 'calendar'
    public:
      '/visualize/calendar': 'calendar'

  handlers:
    calendar: calendar
