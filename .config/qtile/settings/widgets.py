from libqtile import widget
from .theme import colors

# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)

def base(fg='text', bg='dark'): 
    return {
        'foreground': colors[fg],
        'background': colors[bg]
    }

def separator_less():
    return widget.Sep(**base(), linewidth=0, padding=10)

def separator():
    return widget.Sep(**base(), linewidth=0, padding=20)


def icon(fg='text', bg='dark', fontsize=16, text="?"):
    return widget.TextBox(
        **base(fg, bg),
        fontsize=fontsize,
        text=text,
        padding=3
    )


def powerline(fg="light", bg="dark"):
    return widget.TextBox(
        **base(fg, bg),
        text="", # Icon: nf-oct-triangle_left
        fontsize=37,
        padding=-4,
    )

def powerline(fg="light", bg="dark"):
    return widget.TextBox(
        **base(fg, bg),
        text="", # Icon: nf-oct-triangle_left
        fontsize=37,
        padding=-4,
    )


def workspaces(): 
    return [
        separator_less(),
        widget.GroupBox(
            **base(fg='light'),
            font='UbuntuMono Nerd Font',
            fontsize=18,
            margin_y=2,
            margin_x=0,
            padding_y=8,
            padding_x=5,
            borderwidth=1,
            active=colors['active'],       #white
            inactive=colors['inactive'],   #grey
            rounded=False,
            highlight_method='block',
            urgent_alert_method='block',
            urgent_border=colors['urgent'], #red
            this_current_screen_border=colors['focus'], #blue
            this_screen_border=colors['grey'],      #grey
            other_current_screen_border=colors['dark'], 
            other_screen_border=colors['dark'],
            disable_drag=True
        ),
        separator(),
        separator(),
        separator(),
        separator(),
        widget.WindowName(**base(fg='light'), fontsize=14, padding=5),
        separator(),
    ]


primary_widgets = [
    *workspaces(),

    separator(),

    powerline('color4', 'dark'),

    icon(bg="color4", text=' '), # Icon: nf-fae-chip

    widget.CPU(
        **base(bg='color4'),
        format='{load_percent}% '
    ),

    powerline('color5', 'color4'),    

    icon(bg="color5", text=' '), # Icon: nf-fa-memory

    widget.Memory(
        **base(bg='color5'),
        measure_mem='G',
        format='{MemUsed:.2f}{mm}/{MemTotal:.1f}{mm} ',
        update_interval=2.0
    ),

    powerline('color3', 'color5'),

    icon(bg="color3", text=' '),  # Icon: nf-fa-feed
    
    widget.Net(**base(bg='color3'), interface='wlo1'),

    powerline('color2', 'color3'),

    widget.CurrentLayoutIcon(**base(bg='color2'), scale=0.65),

    widget.CurrentLayout(**base(bg='color2'), padding=5),

    powerline('color1', 'color2'),

    icon(bg="color1", fontsize=17, text=' '), # Icon: nf-mdi-calendar_clock

    widget.Clock(**base(bg='color1'), format='%d/%m/%Y - %H:%M '),

    powerline('light', 'color1'),

    widget.Systray(background=colors['light'], padding=5),

]

secondary_widgets = [
    *workspaces(),

    separator(),

    powerline('color1', 'dark'),

    widget.CurrentLayoutIcon(**base(bg='color1'), scale=0.65),

    widget.CurrentLayout(**base(bg='color1'), padding=5),

    powerline('color2', 'color1'),

    widget.Clock(**base(bg='color2'), format='%d/%m/%Y - %H:%M '),

    powerline('dark', 'color2'),
]

widget_defaults = {
    'font': 'UbuntuMono Nerd Font Bold',
    'fontsize': 14,
    'padding': 1,
}
extension_defaults = widget_defaults.copy()
