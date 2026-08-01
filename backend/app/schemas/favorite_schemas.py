from pydantic import BaseModel

class CreateListSchema(BaseModel):
    name: str

class RenameListSchema(BaseModel):
    name: str

# class AddFavoriteItemSchema(BaseModel):
#     place_id: str
class AddFavoriteItemSchema(BaseModel):
    item_id: str
    item_type: str   # place, hotel, package