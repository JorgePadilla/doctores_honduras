module AgendaHelper
  HOUR_PX = 64 # vertical pixels per hour in the calendar grid
  MIN_BLOCK_PX = 26

  # [start_hour, end_hour] for the calendar grid, derived from the doctor's branch
  # schedules (earliest open → latest close), with a sensible fallback.
  def agenda_hour_bounds(branches)
    schedules = BranchSchedule.where(doctor_branch_id: Array(branches).map(&:id))
    opens = schedules.filter_map(&:opens_at).min
    closes = schedules.filter_map(&:closes_at).max

    start_hour = opens ? opens.hour : 7
    end_hour = if closes
      closes.min.zero? ? closes.hour : closes.hour + 1
    else
      19
    end

    start_hour = [ start_hour, 0 ].max
    end_hour = [ end_hour, start_hour + 1 ].max
    [ start_hour, [ end_hour, 24 ].min ]
  end

  def agenda_grid_height_px(start_hour, end_hour)
    (end_hour - start_hour) * HOUR_PX
  end

  # Pixels from the top of the grid to a given Time (an appointment time column).
  def minutes_to_px(hour, minute, start_hour)
    (((hour * 60 + minute) - start_hour * 60) * HOUR_PX / 60.0).round
  end

  def appt_top_px(appt, start_hour)
    minutes_to_px(appt.start_time.hour, appt.start_time.min, start_hour)
  end

  def appt_height_px(appt)
    [ (appt.duration_minutes * HOUR_PX / 60.0).round, MIN_BLOCK_PX ]
.max
  end

  # Position of the "now" line within the grid, or nil if outside the visible range.
  def now_line_px(start_hour, end_hour)
    now = Time.current
    return nil unless now.hour >= start_hour && now.hour < end_hour
    minutes_to_px(now.hour, now.min, start_hour)
  end

  # Lay out a day's appointments into side-by-side lanes so overlapping ones don't
  # stack on top of each other. Returns [{ appt:, lane:, lanes: }, ...] where `lane`
  # is the 0-based column and `lanes` is how many columns share that overlap cluster.
  def layout_appointments(appts)
    sorted = appts.to_a.sort_by { |a| [ a.start_time, a.end_time ] }
    results = []
    i = 0
    while i < sorted.length
      cluster = [ sorted[i] ]
      cluster_end = sorted[i].end_time
      j = i + 1
      while j < sorted.length && sorted[j].start_time < cluster_end
        cluster << sorted[j]
        cluster_end = [ cluster_end, sorted[j].end_time ].max
        j += 1
      end

      cols = [] # cols[k] = end_time of the last appt placed in column k
      placements = []
      cluster.each do |a|
        idx = (0...cols.length).find { |k| cols[k] <= a.start_time }
        if idx.nil?
          idx = cols.length
          cols << a.end_time
        else
          cols[idx] = a.end_time
        end
        placements << [ a, idx ]
      end

      placements.each { |a, idx| results << { appt: a, lane: idx, lanes: cols.length } }
      i = j
    end
    results
  end

  # Inline CSS for a lane's horizontal position (gap_px of breathing room per side).
  def lane_style(lane, lanes, gap_px)
    width = (100.0 / lanes).round(4)
    left = (lane * width).round(4)
    "left:calc(#{left}% + #{gap_px}px); width:calc(#{width}% - #{gap_px * 2}px)"
  end
end
