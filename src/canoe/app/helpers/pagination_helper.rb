# rubocop:disable Rails/OutputSafety
module PaginationHelper
  def current_page
    @current_page ||= params.fetch(:page, "1").to_i
  end

  def pagination_page_size
    10
  end

  def page_button(page_number, link)
    css_class = current_page == page_number ? "active" : ""
    link_address = link_plus_page_param(link, page_number)
    onclick_action = (current_page == page_number ? "return false;" : "")

    output = "<li class='#{css_class}'>"
    output << "<a href='#{link_address}' onclick='#{onclick_action}'>#{page_number}</a>"
    output << "</li>"

    output.html_safe
  end

  def page_gap
    "<li class='disabled'><a href='#' onclick='return false;'>...</a></li>".html_safe
  end

  def previous_page_button(link)
    previous_page = current_page - 1
    if previous_page < 1 # no previous page
      "<li class='active'><a href='#' onclick='return false;'>&laquo;</a></li>".html_safe
    else
      link_address = link_plus_page_param(link, previous_page)
      "<li><a href='#{link_address}'>&laquo;</a></li>".html_safe
    end
  end

  def next_page_button(last_page, link)
    next_page = current_page + 1
    if next_page > last_page
      "<li class='active'><a href='#' onclick='return false;'>&raquo;</a></li>".html_safe
    else
      link_address = link_plus_page_param(link, next_page)
      "<li><a href='#{link_address}'>&raquo;</a></li>".html_safe
    end
  end

  def link_plus_page_param(url, page_num)
    link_address = url
    if link_address =~ /\?/
      link_address += "&page=#{page_num}"
    else
      link_address += "?page=#{page_num}"
    end
    link_address
  end

  def link_minus_page_param(url)
    if url =~ /page\=(\d*)/
      url.gsub!(/page\=(\d*)/, "")
      url.gsub!(/\&\&/, "") # take care of any double &'s now
      url.gsub!(/\?$/, "") # take care of any dangling ?
      url
    else # no page param found
      url
    end
  end

  def pagination_links(item_count, total_count)
    # don't bother with pagination if we don't even have a full page...
    if total_count > item_count
      first_page = 1
      last_page  = (total_count / pagination_page_size.to_f).ceil

      # show two on either side of current unless we are at the edge
      range_start_page = current_page - 2
      range_start_page = [range_start_page, 2].max
      range_end_page   = current_page + 2
      range_end_page   = [last_page - 1, range_end_page].min
      range = (range_start_page..range_end_page).to_a

      current_link = link_minus_page_param(request.fullpath)

      output = "<div class='pagination'>"
      output << previous_page_button(current_link)
      output << page_button(first_page, current_link)
      if range_start_page > first_page + 2
        output << page_gap
      elsif range_start_page > first_page + 1
        output << page_button(first_page + 1, current_link)
      end
      range.each do |this_page|
        output << page_button(this_page, current_link)
      end
      if range_end_page < last_page - 2
        output << page_gap
      elsif range_end_page < last_page - 1
        output << page_button(last_page - 1, current_link)
      end
      output << page_button(last_page, current_link)
      output << next_page_button(last_page, current_link)
      output << "</div>"

      output.html_safe
    end
  end
end
