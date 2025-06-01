{
    'name': 'Escuela Postgrado - Estudiantes',
    'version': '18.0.1.0.0',
    'category': 'Education',
    'summary': 'Gestión de estudiantes de postgrado',
    'description': """
        Módulo para la gestión integral de estudiantes de postgrado:
        - Registro de estudiantes
        - Gestión de programas académicos
        - Seguimiento académico
        - Reportes y estadísticas
    """,
    'author': 'Escuela de Postgrado',
    'website': 'https://www.escuelapostgrado.edu.pe',
    'depends': ['base', 'mail', 'escuela_base'],
    'data': [
        'security/ir.model.access.csv',
        'security/estudiante_security.xml',
        'views/estudiante_views.xml',
        'views/programa_views.xml',
        'views/menu_views.xml',
        'data/programa_data.xml',
    ],
    'demo': [
        'demo/estudiante_demo.xml',
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
