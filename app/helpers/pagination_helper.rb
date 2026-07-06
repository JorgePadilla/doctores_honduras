module PaginationHelper
  # Paginación con el sistema de diseño: pills tokenizados, sin estilos inline
  # ni JS de hover ni scale. url_params se preserva en cada enlace.
  def pagination_links(page, total_pages, url_params = {})
    return "" if total_pages <= 1

    base     = "inline-flex items-center justify-center rounded-full border text-sm font-medium transition-colors"
    pill     = "#{base} px-4 py-2"
    num      = "#{base} w-9 h-9"
    idle     = "border-line text-ink hover:bg-primary-soft hover:text-primary-hover dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-700"
    disabled = "border-line text-muted opacity-60 cursor-not-allowed dark:border-slate-700"
    current  = "border-transparent bg-primary-hover text-white"

    html = [ '<nav class="flex flex-wrap items-center gap-1.5" aria-label="Paginación">' ]

    if page > 1
      html << link_to("&laquo; Anterior".html_safe, url_params.merge(page: page - 1), class: "#{pill} #{idle}")
    else
      html << %(<span class="#{pill} #{disabled}">&laquo; Anterior</span>)
    end

    visible_pages(page, total_pages).each do |p|
      if p == :gap
        html << %(<span class="#{num} border-transparent text-muted">…</span>)
      elsif p == page
        html << %(<span class="#{num} #{current}" aria-current="page">#{p}</span>)
      else
        html << link_to(p.to_s, url_params.merge(page: p), class: "#{num} #{idle}")
      end
    end

    if page < total_pages
      html << link_to("Siguiente &raquo;".html_safe, url_params.merge(page: page + 1), class: "#{pill} #{idle}")
    else
      html << %(<span class="#{pill} #{disabled}">Siguiente &raquo;</span>)
    end

    html << "</nav>"
    html.join.html_safe
  end

  # Hasta 7 números centrados en la página actual, con gaps.
  def visible_pages(current_page, total_pages)
    if total_pages <= 7
      (1..total_pages).to_a
    else
      visible = [ 1, total_pages ]
      start_page = [ current_page - 2, 2 ].max
      end_page = [ current_page + 2, total_pages - 1 ].min
      (start_page..end_page).each { |p| visible << p }
      visible.sort!.tap do |pages|
        pages.insert(1, :gap) if pages[1] > 2
        pages.insert(-2, :gap) if pages[-2] < total_pages - 1
      end
    end
  end
end
