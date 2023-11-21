from libqtile import widget
from .theme import colors

# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)

def base(fg='light', bg='dark'): 
    return {
        'foreground': colors[fg],
        'background': colors[bg]
    }

    return widget.Sep(**base(), linewidth=0, padding=10)

def separator():
    return widget.Sep(**base(), linewidth=0, padding=20)


def icon(fg='light', bg='dark', fontsize=16, text="?",padding=3):
    return widget.TextBox(
        **base(fg, bg),
        fontsize=fontsize,
        text=text,
        padding=padding
    )


def powerline(fg="light", bg="dark"):
    return widget.TextBox(
        font = "UbuntuMono Nerd Font ",
        text="|", 
        fontsize=27,
        padding_y = 2
    )

def workspaces(): 
    return [
        widget.GroupBox(
            margin_x=0,
            margin_y=0,
            padding_y=2,
            font = "UbuntuMono Nerd Font",
            active = colors['active'],
            disable_drag = True,
            fontsize = 16,
            highlight_method = "block",
            urgent_alert_method="block",
            this_current_screen_border = colors['color4'],
            rounded=False,
        ),
        separator(),
        separator(),
        separator(),
        separator(),
        widget.WindowName(**base(fg='light'), fontsize=12, padding=5),
    ]


primary_widgets = [
    *workspaces(),
    separator(),

    powerline('color5', 'color4'),    

    icon(fontsize=12, bg="dark", text=' '), # Icon: nf-fae-chip

    widget.CPU(
        **base(bg='dark'),
        fontsize = 12,
        format='{load_percent}% '
    ),

    icon(fontsize=12, bg="dark", text=' '), # Icon: nf-fae-chip

    widget.ThermalSensor(
        **base(bg='dark'),
        fontsize=12
    ),

    powerline('color5', 'color4'),    

    icon(bg="dark", text=' ',fontsize=14), # Icon: nf-fa-memory
    
    widget.Memory(
        **base(bg='dark'),
        fontsize=12,
        measure_mem='G',
        format='{MemUsed:.2f}{mm}/{MemTotal:.1f}{mm} ',
        update_interval=2.0
    ),

    powerline('color3', 'color5'),

    icon(fontsize=13,bg="dark", text=' '),  # Icon: nf-fa-feed
    
    widget.Net(**base(bg='dark'),fontsize=12,format='{down:6.2f}{down_suffix:<2} ↓↑ {up:6.2f}{up_suffix:<2}', interface='wlo1'),

    powerline('color2', 'color3'),

    widget.CurrentLayoutIcon(**base(bg='dark'), scale=0.60),

    widget.CurrentLayout(**base(bg='dark'), padding=5, fontsize=12),

    powerline('color1', 'color2'),

    icon(fontsize=14,bg='dark',text=' '),

    widget.PulseVolume(
        **base(bg='dark'),
        fontsize=12,
        fmt='{}',
        device='default',
        update_interval=0.05,
    ),

    powerline('color4', 'color1'),

    widget.KeyboardLayout(
        **base(bg='dark'),
        fontsize=12,
        configured_keyboards=['us', 'es'],
        display_map={'us': 'US', 'es': 'ES'},
        option='caps:escape',
        padding=5
    ),

    powerline('color1', 'color2'),

    widget.Clock(**base(bg='dark'), format='%d/%m/%Y - %H:%M ',fontsize=12),

    widget.Systray(background=colors['active'],padding=5),

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
    'font': 'JetBrainsMono Nerd Font',
    'fontsize': 14,
    'padding': 1,
}
extension_defaults = widget_defaults.copy()
