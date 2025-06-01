{
    'name': 'Escuela Postgrado - Base',
    'version': '18.0.1.0.0',
    'category': 'Education',
    'summary': 'Módulo base para el sistema de postgrado',
    'description': """
        Módulo base que proporciona funcionalidades fundamentales
        para el sistema de gestión de postgrado.
    """,
    'author': 'Escuela de Postgrado',
    'website': 'https://www.escuelapostgrado.edu.pe',
    'depends': ['base', 'web'],
    'data': [
        'security/ir.model.access.csv',
        'views/menu_views.xml',
    ],
    'demo': [],
    'installable': True,
    'application': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
