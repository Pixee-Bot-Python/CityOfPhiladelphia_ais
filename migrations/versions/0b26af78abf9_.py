"""empty message

Revision ID: 0b26af78abf9
Revises: f8ceea8e623a
Create Date: 2017-05-26 09:35:20.844819

"""

# revision identifiers, used by Alembic.
revision = '0b26af78abf9'
down_revision = 'f8ceea8e623a'

from alembic import op
import sqlalchemy as sa


def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.add_column('address_summary', sa.Column('eclipse_location_id', sa.Text(), nullable=True))
    op.drop_column('address_summary', 'eclipse_object_id')
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.add_column('address_summary', sa.Column('eclipse_object_id', sa.TEXT(), autoincrement=False, nullable=True))
    op.drop_column('address_summary', 'eclipse_location_id')
    ### end Alembic commands ###