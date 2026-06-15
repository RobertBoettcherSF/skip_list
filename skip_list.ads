--  skip_list.ads
--  
--  SPARK specification for Skip List - Probabilistic alternative to trees
--  
--  Skip Lists provide expected O(log n) search, insert, and delete operations
--  through probabilistic level assignment. Ideal for verification due to
--  deterministic behavior given a fixed random seed.
--  
--  Version: 0.06
--  Author: Vibe Code Agent
--  Date: 2024

with Ada.Containers;

package Skip_List with
   SPARK_Mode => On
is

   -- Maximum level for the skip list (affects memory usage and performance)
   -- Typical value: 16-32 for most applications
   Max_Level : constant Positive := 32;

   -- Probability factor for level generation (typically 0.5)
   -- Higher values create taller lists with fewer nodes per level
   P : constant := 0.5;

   -- Type for element values
   type Element_Type is range Integer'First .. Integer'Last;

   -- Type for node levels (0 to Max_Level)
   type Level_Type is range 0 .. Max_Level;

   -- Forward declaration for Node
   type Node;
   type Node_Access is access Node;

   -- Skip List type
   type Skip_List_Type is tagged private;

   -- Exception for duplicate keys
   Duplicate_Key_Error : exception;

   -- Exception for empty list operations
   Empty_List_Error : exception;

   -- Initialize an empty skip list
   procedure Initialize (List : out Skip_List_Type);

   -- Clear the skip list, freeing all memory
   procedure Clear (List : in out Skip_List_Type);

   -- Check if the skip list is empty
   function Is_Empty (List : Skip_List_Type) return Boolean;

   -- Get the number of elements in the skip list
   function Length (List : Skip_List_Type) return Ada.Containers.Count_Type;

   -- Insert a key-value pair into the skip list
   -- Returns True if insertion was successful, False if key already exists
   procedure Insert (List : in out Skip_List_Type; 
                     Key   : Element_Type;
                     Value : Element_Type;
                     Success : out Boolean);

   -- Search for a key and return its value
   -- Returns True if found, False otherwise
   procedure Search (List  : Skip_List_Type;
                    Key   : Element_Type;
                    Value : out Element_Type;
                    Found : out Boolean);

   -- Delete a key from the skip list
   -- Returns True if deletion was successful, False if key not found
   procedure Delete (List : in out Skip_List_Type;
                    Key  : Element_Type;
                    Success : out Boolean);

   -- Check if a key exists in the skip list
   function Contains (List : Skip_List_Type;
                     Key  : Element_Type) return Boolean;

   -- Get the minimum key in the skip list
   function Min_Key (List : Skip_List_Type) return Element_Type
     with Pre => not Is_Empty (List);

   -- Get the maximum key in the skip list
   function Max_Key (List : Skip_List_Type) return Element_Type
     with Pre => not Is_Empty (List);

   -- Iterate through all elements in sorted order
   -- This is a forward iterator
   type Cursor is private;

   -- No_Element cursor value
   No_Element : constant Cursor;

   -- Check if cursor points to an element
   function Has_Element (Position : Cursor) return Boolean;

   -- Get the key at the current cursor position
   function Key (Position : Cursor) return Element_Type
     with Pre => Has_Element (Position);

   -- Get the value at the current cursor position
   function Value (Position : Cursor) return Element_Type
     with Pre => Has_Element (Position);

   -- Move cursor to the first element
   function First (List : Skip_List_Type) return Cursor;

   -- Move cursor to the next element
   function Next (List : Skip_List_Type; Position : Cursor) return Cursor
     with Pre => Has_Element (Position);

   -- Set the random seed for deterministic probabilistic behavior
   -- This is crucial for verification and testing
   procedure Set_Random_Seed (Seed : Integer);

   -- Get the current level of the skip list (highest non-empty level)
   function Current_Level (List : Skip_List_Type) return Level_Type;

private

   -- Node structure for skip list
   type Node is record
      Key     : Element_Type;
      Value   : Element_Type;
      Forward : array (Level_Type) of Node_Access;
   end record;

   -- Skip List structure
   type Skip_List_Type is tagged record
      Head : Node_Access;
      Current_Level : Level_Type := 0;
      Count : Ada.Containers.Count_Type := 0;
   end record;

   -- Cursor for iteration
   type Cursor is record
      Node_Ptr : Node_Access;
   end record;

   -- No_Element cursor
   No_Element : constant Cursor := (Node_Ptr => null);

end Skip_List;
