$(document).ready(function () {
  'use strict';

  Spree.routes.fulfillments_api = Spree.pathFor('api/fulfillments');

  $('[data-hook=admin_shipment_form] a.fulfill').on('click', function () {
    var link = $(this);
    var shipment_number = link.data('shipment-number');
    var url = Spree.url(Spree.routes.fulfillments_api + '/' + shipment_number + '/start.json');
    $.ajax({
      type: 'PUT',
      url: url
    }).done(function () {
      window.location.reload();
    }).error(function (msg) {
      console.log(msg);
    });
  });
});
