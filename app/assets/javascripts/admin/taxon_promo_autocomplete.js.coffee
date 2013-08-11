$ ->
  if ($newProductRuleForm = $('#new_product_rule_form')).length
    setupTaxonAutocomplete = ->
      $('input.promo-taxon-autocomplete').each (i,e) ->
        $input = $(e)
        unless $input.data('select2')
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
    setupTaxonAutocomplete()
    $('#new_product_rule_form').on('ajax:complete.rails', setupTaxonAutocomplete)
