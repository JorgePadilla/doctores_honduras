module PaginationHelper
  # Custom pagination helper with Tailwind CSS styling
  def pagination_links(page, total_pages, url_params = {})
    return '' if total_pages <= 1
    
    html = ['<div class="flex items-center space-x-1">']    
    
    # Previous link
    if page > 1
      prev_params = url_params.merge(page: page - 1)
      html << link_to('&laquo; Anterior'.html_safe, prev_params, class: 'relative inline-flex items-center px-4 py-2 text-sm font-medium text-white border border-transparent rounded-full transition-all shadow-sm hover:shadow-md transform hover:scale-105', style: 'background-color: #38bdf8;', onmouseover: "this.style.backgroundColor='#0ea5e9';")
    else
      html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-300 bg-gray-100 border border-transparent rounded-full cursor-not-allowed opacity-70">&laquo; Anterior</span>'
    end
    
    # Page links
    visible_pages(page, total_pages).each do |p|
      if p == :gap
        html << '<span class="relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-transparent">…</span>'
      elsif p == page
        html << "<span class=\"relative inline-flex items-center w-8 h-8 justify-center text-sm font-bold text-white rounded-full shadow-md\" style=\"background-color: #38bdf8;\">#{p}</span>"
      else
        page_params = url_params.merge(page: p)
        html << link_to(p.to_s, page_params, class: 'relative inline-flex items-center w-8 h-8 justify-center text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-full hover:text-white transition-all hover:shadow-sm transform hover:scale-105', onmouseover: "this.style.backgroundColor='#38bdf8'; this.style.color='white';", onmouseout: "this.style.backgroundColor='white'; this.style.color='#4b5563';")
      end
    end
    
    # Next link
    if page < total_pages
      next_params = url_params.merge(page: page + 1)
      html << link_to('Siguiente &raquo;'.html_safe, next_params, class: 'relative inline-flex items-center px-4 py-2 text-sm font-medium text-white border border-transparent rounded-full transition-all shadow-sm hover:shadow-md transform hover:scale-105', style: 'background-color: #38bdf8;', onmouseover: "this.style.backgroundColor='#0ea5e9';")
    else
      html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-300 bg-gray-100 border border-transparent rounded-full cursor-not-allowed opacity-70">Siguiente &raquo;</span>'
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
