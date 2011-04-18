##
# MariCMS
# Copyright 2011 金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
# http://www.maricms.com

# This file is part of MariCMS, an open source content management system.

# MariGold MariCMS is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
# 
# Under the terms of the GNU Affero General Public License you must release the
# complete source code for any application that uses any part of MariCMS
# (system header files and libraries used by the operating system are excluded).
# These terms must be included in any work that has MariCMS components.
# If you are developing and distributing open source applications under the
# GNU Affero General Public License, then you are free to use MariCMS.
# 
# If you are deploying a web site in which users interact with any portion of
# MariCMS over a network, the complete source code changes must be made
# available.  For example, include a link to the source archive directly from
# your web site.
# 
# For OEMs, ISVs, SIs and VARs who distribute MariCMS with their products,
# and do not license and distribute their source code under the GNU
# Affero General Public License, MariGold provides a flexible commercial
# license.
# 
# To anyone in doubt, we recommend the commercial license. Our commercial license
# is competitively priced and will eliminate any confusion about how
# MariCMS can be used and distributed.
# 
# MariCMS is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with MariCMS.  If not, see <http://www.gnu.org/licenses/>.
# 
# Attribution Notice: MariCMS is an Original Work of software created
# by  金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
##

module ApplicationHelper
  
  def datatable(columns=nil, opts={})
    sort_by = opts[:sort_by] || nil
    additional_data = opts[:additional_data] || {}
    search = opts[:search].present? ? opts[:search].to_s : "true"
    search_label = opts[:search_label] || "Search"
    processing = image_tag("datatable_spinner.gif") || "Processing"
    persist_state = opts[:persist_state].present? ? opts[:persist_state].to_s : "true"
    table_dom_id = opts[:table_dom_id] ? "##{opts[:table_dom_id]}" : ".datatable"
    per_page = opts[:per_page] || opts[:display_length]|| 5
    no_records_message = opts[:no_records_message] || nil
    auto_width = opts[:auto_width].present? ? opts[:auto_width].to_s : "true"
    row_callback = opts[:row_callback] || nil

    append = opts[:append] || nil

    ajax_source = opts[:ajax_source] || nil
    server_side = opts[:ajax_source].present?

    additional_data_string = ""
    additional_data.each_pair do |name,value|
      additional_data_string = additional_data_string + ", " if !additional_data_string.blank? && value
      additional_data_string = additional_data_string + "{'name': '#{name}', 'value':'#{value}'}" if value
    end

    %Q{
    <script type="text/javascript">
    $(function() {
        $('#{table_dom_id}').dataTable({
          "oLanguage": {
            "sSearch": "#{search_label}",
            #{"'sZeroRecords': '#{no_records_message}'," if no_records_message}
            "sProcessing": '#{processing}'
          },
          "sPaginationType": "full_numbers",
          "iDisplayLength": #{per_page},
          "bProcessing": true,
          "bServerSide": #{server_side},
          "bLengthChange": true,
          "aLengthMenu": [[5, 10, 25, 50, 100], [5, 10, 25, 50, 100]],
          "bStateSave": #{persist_state},
          "bFilter": #{search},
          "bAutoWidth": #{auto_width},
          "bJQueryUI": true,
          #{"'aaSorting': [#{sort_by}]," if sort_by}
          "bSort": false,
          #{"'sAjaxSource': '#{ajax_source}'," if ajax_source}
          #{"'aoColumns': [#{formatted_columns(columns)}]," if columns}
          #{"'fnRowCallback': function( nRow, aData, iDisplayIndex ) { #{row_callback} }," if row_callback}
          "fnServerData": function ( sSource, aoData, fnCallback ) {
            aoData.push( #{additional_data_string} );
            $.getJSON( sSource, aoData, function (json) {
              fnCallback(json);
            });
          }
        })#{append};
    });
    </script>
    }
  end

  private
    def formatted_columns(columns)
      i = 0
      columns.map {|c|
        i += 1
        if c.nil? or c.empty?
          "null"
        else
          searchable = c[:searchable].to_s.present? ? c[:searchable].to_s : "true"
          sortable = c[:sortable].to_s.present? ? c[:sortable].to_s : "true"

          "{
          'sType': '#{c[:type] || "string"}',
          'bSortable':#{sortable},
          'bSearchable':#{searchable}
          #{",'sClass':'#{c[:class]}'" if c[:class]}
          }"
        end
      }.join(",")
    end

end
