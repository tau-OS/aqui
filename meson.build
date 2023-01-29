project(
    'com.fyralabs.Aqui',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.57.0'
)

app_nickname = 'aqui'

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

conf_data = configuration_data()
conf_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
conf_data.set_quoted('PKGDATADIR', get_option('prefix') / get_option('datadir'))
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
config_header = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

sources = files(
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Spinner.vala',
    'src/GeoClue.vala',
    'src/LocationMarker.vala',
    'src/Wikipedia.vala',
)

asresources = gnome.compile_resources(
    'as-resources', 'data/aqui.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name (),
    config_header,
    sources,
    asresources,
    dependencies: [
        dependency('gio-2.0'),
        dependency('libhelium-1'),
        dependency('shumate-1.0'),
        dependency('gtk4'),
        dependency('geocode-glib-2.0'),
        dependency('libgeoclue-2.0'),
        dependency('libsoup-3.0'),
        dependency('json-glib-1.0'),
    ],
    install: true
)

subdir('data')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
