package models

type Category struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Slug     string `json:"slug"`
	ParentID string `json:"parent_id,omitempty"`
	Position int    `json:"position"`
}

type AddCategory struct {
	Name     string `json:"name"`
	Slug     string `json:"slug"`
	ParentID string `json:"parent_id,omitempty"`
	Position int    `json:"position"`
}

type UpdateCategory struct {
	Name     *string `json:"name,omitempty"`
	Slug     *string `json:"slug,omitempty"`
	ParentID *string `json:"parent_id,omitempty"`
	Position *int    `json:"position,omitempty"`
}
