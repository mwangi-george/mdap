"""Creating first tables

Revision ID: d1175bf39469
Revises: 
Create Date: 2024-09-14 14:47:30.498282

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'd1175bf39469'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('users',
                    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
                    sa.Column('name', sa.String(), nullable=False),
                    sa.Column('email', sa.String(), nullable=False),
                    sa.Column('mpesa_number', sa.String(), nullable=False),
                    sa.Column('username', sa.String(), nullable=False),
                    sa.Column('password', sa.String(), nullable=False),
                    sa.PrimaryKeyConstraint('id')
                    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_mpesa_number'), 'users', ['mpesa_number'], unique=True)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)
    op.create_table('transactions',
                    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
                    sa.Column('transaction_code', sa.String(), nullable=False),
                    sa.Column('transaction_amount', sa.String(), nullable=True),
                    sa.Column('counterparty', sa.String(), nullable=True),
                    sa.Column('date', sa.String(), nullable=False),
                    sa.Column('time', sa.String(), nullable=False),
                    sa.Column('new_balance', sa.String(), nullable=False),
                    sa.Column('transaction_cost', sa.String(), nullable=False),
                    sa.Column('transaction_type', sa.String(), nullable=False),
                    sa.Column('user_id', sa.Integer(), nullable=False),
                    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
                    sa.PrimaryKeyConstraint('id')
                    )
    op.create_index(op.f('ix_transactions_transaction_code'), 'transactions', ['transaction_code'], unique=True)
    op.create_index(op.f('ix_transactions_transaction_type'), 'transactions', ['transaction_type'], unique=False)
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_transactions_transaction_type'), table_name='transactions')
    op.drop_index(op.f('ix_transactions_transaction_code'), table_name='transactions')
    op.drop_table('transactions')
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_index(op.f('ix_users_mpesa_number'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
    # ### end Alembic commands ###
