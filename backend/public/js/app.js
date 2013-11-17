var locations = t.Locations
for(var i=0; i < locations.length; i++)
  console.log(locations[i]);

App = Ember.Application.create({});

App.Router.map(function() {
  this.resource('locations', function() {
    this.resource('location', { path: ':slug' });
  });


  this.resource('about');
});

App.LocationsRoute = Ember.Route.extend({
  model: function() {
    console.log(locations[0]);
    return locations;
  }
});

App.LocationRoute = Ember.Route.extend({
  model: function(params) {
    console.log(params);
    return locations.findBy('slug', params.slug);
  }
});

App.LocationController = Ember.ObjectController.extend({
  isEditing: false,

  edit: function() {
    this.set('isEditing', true);
  },

  doneEditing: function() {
    this.set('isEditing', false);
    this.get('store').commit();
  }
});

Handlebars.registerHelper('editLocation', function(options) {
    return '<a href="allLocations#/locations/' + this.slug + '" class="btn btn-success edit-btn">Edit</a>';
  });

// var showdown = new Showdown.converter();

// Ember.Handlebars.helper('format-markdown', function(input) {
//   return new Handlebars.SafeString(showdown.makeHtml(input));
// });

// Ember.Handlebars.helper('format-date', function(date) {
//   return moment(date).fromNow();
// });
