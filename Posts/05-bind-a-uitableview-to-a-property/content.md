A couple weeks ago I wrote a post [Objective-C Bindings](/posts/2013/01/28/objective-c-bindings) about a library I started that allows you to bind the property of one object to the property of another. This week I added a new type of property binding that allows you to bind a UITableView directly to a to-many property.

You can find the code on [github](https://github.com/drewag/property-bindings).

Usage
====

The binding will set itself as the data source for the table view and an insertion, deletion, or replacement KVO event is triggered on the observed property the binding will automatically add, remove, or update the appropriate cells.

The binding also takes a block that should convert an object from the to-many property into a cell. This is called every time the table view asks for a cell from its data source.

The binding is available in a UITableView extension. Connecting the binding looks like the following:

    // objectivec
    #import <PropertyBindings/PropertyBindings.h>

    // ...

    [self.tableView
        bindToObserved:sourceObject
        withArrayKeyPath:@"names"
        cellCreationBlock:^UITableViewCell *(NSString *name) {
            UITableViewCell *cell = [self.tableView
            dequeueReusableCellWithIdentifier:CellIdentifier];

            if (!cell) {
                cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier
                ];
                [cell autorelease];
            }

            cell.textLabel.text = name;

            return cell;
        }
    ];

Improvements
=========

Array properties do not by default trigger the granular insertion, deletion, and replacement notifications required for the binding to work. It would be better if the notifications were handled automatically by the binding.

The first step would be to handle this for arrays. One possible solution is to replace the array with a proxy object that would trigger the notifications. However the setter for the property would have to be swizzled to ensure the proxy stays in place when the property is overwritten.
