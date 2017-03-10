import Box2D 2.0

/*
  This body places 32-pixel wide invisible static bodies around the screen,
  to avoid stuff getting out.
*/
Body {
    world: physicsWorld
    property variant screen
    Box {
        y: screen.height
        width: screen.width
        height: 32
        categories: Box.Category16
        restitution: 1
    }
    Box {
        y: -32
        height: 32
        width: screen.width
        categories: Box.Category16
        restitution: 1
    }
    Box {
        x: -32
        width: 32
        height: screen.height
        categories: Box.Category16
        restitution: 1
    }
    Box {
        x: screen.width
        width: 32
        height: screen.height
        categories: Box.Category16
        restitution: 1
    }
}
