from odoo import api, fields, models


class InstallDemo(models.Model):
    _name = "install.demo"
    _description = "Odoo Install Demo Record"
    _order = "create_date desc"

    name = fields.Char(string="Name", required=True)
    status = fields.Selection(
        selection=[
            ("draft", "Draft"),
            ("ok", "OK"),
            ("ko", "Failed"),
        ],
        string="Status",
        default="draft",
        required=True,
    )
    note = fields.Text(string="Note")
    check_count = fields.Integer(string="Check count", default=0, readonly=True)

    @api.model
    def smoke_test(self, name="install-check"):
        """Create one record then flip it to OK. Useful for post-install verification."""
        record = self.create({"name": name, "status": "draft"})
        record.write({"status": "ok", "check_count": record.check_count + 1})
        return record.id

    def action_mark_ok(self):
        for rec in self:
            rec.write({"status": "ok", "check_count": rec.check_count + 1})
        return True
