# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError
from datetime import date


class EscuelaEstudiante(models.Model):
    _name = 'escuela.estudiante'
    _description = 'Estudiante de Postgrado'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'name'

    # Información Personal
    name = fields.Char('Nombre Completo', required=True, tracking=True)
    codigo_estudiante = fields.Char('Código de Estudiante', required=True, tracking=True)
    email = fields.Char('Email', required=True, tracking=True)
    telefono = fields.Char('Teléfono')
    documento_identidad = fields.Char('DNI/Pasaporte', required=True)
    fecha_nacimiento = fields.Date('Fecha de Nacimiento')
    edad = fields.Integer('Edad', compute='_compute_edad', store=True)
    
    # Información Académica
    programa_id = fields.Many2one('escuela.programa', string='Programa', required=True, tracking=True)
    fecha_ingreso = fields.Date('Fecha de Ingreso', default=fields.Date.today, tracking=True)
    estado = fields.Selection([
        ('activo', 'Activo'),
        ('inactivo', 'Inactivo'),
        ('egresado', 'Egresado'),
        ('retirado', 'Retirado'),
        ('suspendido', 'Suspendido')
    ], string='Estado', default='activo', tracking=True)
    
    semestre_actual = fields.Integer('Semestre Actual', default=1)
    creditos_completados = fields.Integer('Créditos Completados', default=0)
    promedio_general = fields.Float('Promedio General', digits=(3, 2))
    
    # Información de Contacto
    direccion = fields.Text('Dirección')
    ciudad = fields.Char('Ciudad')
    pais = fields.Char('País', default='Perú')
    
    # Campos adicionales
    active = fields.Boolean('Activo', default=True)
    notas = fields.Text('Notas')
    
    # Campos computados
    programa_tipo = fields.Selection(related='programa_id.tipo', string='Tipo de Programa', store=True)
    programa_codigo = fields.Char(related='programa_id.code', string='Código Programa', store=True)
    
    @api.depends('fecha_nacimiento')
    def _compute_edad(self):
        for estudiante in self:
            if estudiante.fecha_nacimiento:
                today = date.today()
                estudiante.edad = today.year - estudiante.fecha_nacimiento.year - (
                    (today.month, today.day) < (estudiante.fecha_nacimiento.month, estudiante.fecha_nacimiento.day)
                )
            else:
                estudiante.edad = 0
    
    @api.constrains('codigo_estudiante')
    def _check_codigo_unique(self):
        for estudiante in self:
            if self.search([('codigo_estudiante', '=', estudiante.codigo_estudiante), ('id', '!=', estudiante.id)]):
                raise ValidationError(_('Ya existe un estudiante con este código.'))
    
    @api.constrains('email')
    def _check_email_format(self):
        for estudiante in self:
            if estudiante.email and '@' not in estudiante.email:
                raise ValidationError(_('El formato del email no es válido.'))
    
    @api.constrains('semestre_actual', 'programa_id')
    def _check_semestre_valid(self):
        for estudiante in self:
            if estudiante.semestre_actual > estudiante.programa_id.duracion_semestres:
                raise ValidationError(_('El semestre actual no puede ser mayor a la duración del programa.'))
    
    @api.model
    def create(self, vals):
        # Generar código automático si no se proporciona
        if not vals.get('codigo_estudiante'):
            programa = self.env['escuela.programa'].browse(vals.get('programa_id'))
            sequence = self.env['ir.sequence'].next_by_code('escuela.estudiante') or '0001'
            vals['codigo_estudiante'] = f"{programa.code}{sequence}"
        
        return super().create(vals)
    
    def name_get(self):
        result = []
        for estudiante in self:
            name = f"[{estudiante.codigo_estudiante}] {estudiante.name}"
            result.append((estudiante.id, name))
        return result
    
    def action_marcar_egresado(self):
        """Acción para marcar estudiante como egresado"""
        for estudiante in self:
            estudiante.estado = 'egresado'
            estudiante.message_post(body=_('Estudiante marcado como egresado.'))
    
    def action_activar(self):
        """Acción para activar estudiante"""
        for estudiante in self:
            estudiante.estado = 'activo'
            estudiante.message_post(body=_('Estudiante activado.'))
    
    def action_suspender(self):
        """Acción para suspender estudiante"""
        for estudiante in self:
            estudiante.estado = 'suspendido'
            estudiante.message_post(body=_('Estudiante suspendido.'))
