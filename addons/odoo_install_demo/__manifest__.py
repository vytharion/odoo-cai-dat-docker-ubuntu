{
    "name": "Odoo Install Demo",
    "version": "19.0.1.0.0",
    "summary": "Module mau de kiem tra Odoo 19 stack vua cai dat chay duoc.",
    "description": "Goi module nho de smoke-test installation: tao mot model don gian, view tree+form, va access rule. Dung sau khi `docker compose up -d` lan dau.",
    "author": "vytharion",
    "license": "MIT",
    "category": "Tools",
    "depends": ["base"],
    "data": [
        "security/ir.model.access.csv",
        "views/m_demo_views.xml",
    ],
    "installable": True,
    "application": False,
    "auto_install": False,
}
