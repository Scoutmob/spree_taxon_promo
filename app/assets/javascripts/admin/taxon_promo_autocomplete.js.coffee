$ ->
  if ($input = $('input.promo-taxon-autocomplete')).length > 0
    $input.select2({
      placeholder: $input.attr('placeholder'),
      multiple: true,
      initSelection: ((element, callback) ->
        $.getJSON("#{Spree.routes.taxon_search}?ids=#{element.val()}", null, (data) -> callback(data['taxons']))
      ),
      ajax: {
        url: Spree.routes.taxon_search,
        datatype: 'json',
        data: (term, page) -> { q: term },
        results: (data, page) -> { results: data['taxons'] }
      },
      formatResult: (taxon) -> taxon.pretty_name,
      formatSelection: (taxon) -> taxon.name
    })


