# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError


class EscuelaPrograma(models.Model):
    _name = 'escuela.programa'
    _description = 'Programa Académico de Postgrado'
    _order = 'name'

    name = fields.Char('Nombre del Programa', required=True)
    code = fields.Char('Código', required=True)
    tipo = fields.Selection([
        ('maestria', 'Maestría'),
        ('doctorado', 'Doctorado'),
        ('diplomado', 'Diplomado'),
        ('especializacion', 'Especialización')
    ], string='Tipo de Programa', required=True)
    
    duracion_semestres = fields.Integer('Duración (Semestres)', default=4)
    creditos_totales = fields.Integer('Créditos Totales', default=48)
    modalidad = fields.Selection([
        ('presencial', 'Presencial'),
        ('virtual', 'Virtual'),
        ('semipresencial', 'Semipresencial')
    ], string='Modalidad', default='presencial')
    
    active = fields.Boolean('Activo', default=True)
    descripcion = fields.Text('Descripción')
    
    # Relaciones
    estudiante_ids = fields.One2many('escuela.estudiante', 'programa_id', string='Estudiantes')
    estudiantes_count = fields.Integer('Número de Estudiantes', compute='_compute_estudiantes_count')
    
    @api.depends('estudiante_ids')
    def _compute_estudiantes_count(self):
        for programa in self:
            programa.estudiantes_count = len(programa.estudiante_ids)
    
    @api.constrains('code')
    def _check_code_unique(self):
        for programa in self:
            if self.search([('code', '=', programa.code), ('id', '!=', programa.id)]):
                raise ValidationError(_('Ya existe un programa con este código.'))
    
    def name_get(self):
        result = []
        for programa in self:
            name = f"[{programa.code}] {programa.name}"
            result.append((programa.id, name))
        return result
