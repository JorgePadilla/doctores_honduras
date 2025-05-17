module PaginationHelper
  # Custom pagination helper with Tailwind CSS styling
  def pagination_links(page, total_pages, url_params = {})
    return '' if total_pages <= 1
    
    html = ['<div class="flex items-center">']
    
    # Previous link
    if page > 1
      prev_params = url_params.merge(page: page - 1)
      html << link_to('&laquo; Anterior'.html_safe, prev_params, class: 'relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-transparent rounded-l-md hover:text-primary-600 hover:border-b-2 hover:border-primary-400 transition-all')
    else
      html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-300 bg-white border border-transparent rounded-l-md cursor-not-allowed">&laquo; Anterior</span>'
    end
    
    # Page links
    visible_pages(page, total_pages).each do |p|
      if p == :gap
        html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-500 bg-white border border-transparent">…</span>'
      elsif p == page
        html << "<span class=\"relative inline-flex items-center px-4 py-2 text-sm font-bold text-primary-700 bg-white border-b-2 border-primary-700\">#{p}</span>"
      else
        page_params = url_params.merge(page: p)
        html << link_to(p.to_s, page_params, class: 'relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-transparent hover:border-b-2 hover:border-primary-400 hover:text-primary-600 transition-all')
      end
    end
    
    # Next link
    if page < total_pages
      next_params = url_params.merge(page: page + 1)
      html << link_to('Siguiente &raquo;'.html_safe, next_params, class: 'relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-transparent rounded-r-md hover:text-primary-600 hover:border-b-2 hover:border-primary-400 transition-all')
    else
      html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-300 bg-white border border-transparent rounded-r-md cursor-not-allowed">Siguiente &raquo;</span>'
    end
    
    html << '</div>'
    html.join.html_safe
  end
  
  # Helper method to determine which page numbers to show
  def visible_pages(current_page, total_pages)
    # Show up to 7 page numbers centered around the current page
    if total_pages <= 7
      (1..total_pages).to_a
    else
      # Always show first and last pages
      visible = [1, total_pages]
      
      # Calculate the range around the current page
      start_page = [current_page - 2, 2].max
      end_page = [current_page + 2, total_pages - 1].min
      
      # Add the range to visible pages
      (start_page..end_page).each { |p| visible << p }
      
      # Sort and add gaps where needed
      visible.sort!.tap do |pages|
        # Add gap after first page if needed
        pages.insert(1, :gap) if pages[1] > 2
        
        # Add gap before last page if needed
        pages.insert(-2, :gap) if pages[-2] < total_pages - 1
      end
    end
  end
end
