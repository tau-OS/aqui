icon_sizes = ['128']

foreach i : icon_sizes
    install_data(
        'icons' / i + '.svg',
        rename: meson.project_name() + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

install_data(
    'icons' / 'aqui' / 'LocationMarker.svg',
    install_dir: get_option('prefix') / get_option('datadir')
)

i18n.merge_file(
    input: app_nickname + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: app_nickname + '.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

install_data(
    app_nickname + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)
