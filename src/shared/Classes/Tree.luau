local TreeNode = {}
TreeNode.__index = TreeNode

function TreeNode.new(value)
    return setmetatable({
        value = value,
        parent = nil,
        children = {}
    }, TreeNode)
end

function TreeNode:add_child(value)
    local child = TreeNode.new(value)
    child.parent = self
    table.insert(self.children, child)
    return child
end

function TreeNode:remove_child(child)
    for i, node in ipairs(self.children) do
        if node == child then
            node.parent = nil
            table.remove(self.children, i)
            return true
        end
    end
    return false
end

function TreeNode:is_leaf()
    return #self.children == 0
end

function TreeNode:depth()
    local depth = 0
    local node = self.parent

    while node do
        depth = depth + 1
        node = node.parent
    end

    return depth
end

function TreeNode:traverse_preorder(callback)
    callback(self)

    for _, child in ipairs(self.children) do
        child:traverse_preorder(callback)
    end
end

function TreeNode:find(predicate)
    if predicate(self) then
        return self
    end

    for _, child in ipairs(self.children) do
        local found = child:find(predicate)
        if found then
            return found
        end
    end

    return nil
end

local Tree = {}
Tree.__index = Tree

function Tree.new(root_value)
    return setmetatable({
        root = TreeNode.new(root_value)
    }, Tree)
end

function Tree:traverse_preorder(callback)
    self.root:traverse_preorder(callback)
end

function Tree:find(predicate)
    return self.root:find(predicate)
end

return Tree