{application,nerves_uevent,
             [{optional_applications,[]},
              {applications,[kernel,stdlib,elixir,logger,property_table]},
              {description,"Simple UEvent monitor for detecting hardware and automatically loading drivers"},
              {modules,['Elixir.NervesUEvent',
                        'Elixir.NervesUEvent.Application',
                        'Elixir.NervesUEvent.UEvent']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.NervesUEvent.Application',[]}}]}.