--  skip_list.adb
--  
--  Ada SPARK implementation for Skip List - Probabilistic alternative to trees
--  
--  This implementation uses a deterministic random number generator for
--  verification purposes. The probabilistic level assignment ensures
--  expected O(log n) operations while maintaining deterministic behavior
--  when a fixed seed is used.
--  
--  Version: 0.19
--  Author: Vibe Code Agent
--  Date: 2024

pragma SPARK_Mode (On);

with Ada.Unchecked_Deallocation;

package body Skip_List is

   -- Local package for random number generation
   -- Using a simple Linear Congruential Generator for deterministic behavior
   -- Note: Uses Float which is not fully SPARK compatible
   package Random_Generator is
      pragma SPARK_Mode (Off);
      type Generator is private;
      
      procedure Initialize (Gen : out Generator; Seed : Integer);
      function Random (Gen : in out Generator) return Float;
      function Random_Level (Gen : in out Generator) return Level_Type;
   private
      type Generator is record
         State : Long_Long_Integer;
      end record;
      
      -- LCG parameters (typical values for good distribution)
      A : constant Long_Long_Integer := 1664525;
      C : constant Long_Long_Integer := 1013904223;
      M : constant Long_Long_Integer := 2**32;
   end Random_Generator;

   package body Random_Generator is
      pragma SPARK_Mode (Off);
      procedure Initialize (Gen : out Generator; Seed : Integer) is
      begin
         Gen.State := Long_Long_Integer(Seed) mod M;
         if Gen.State <= 0 then
            Gen.State := 1;
         end if;
      end Initialize;
      
      function Random (Gen : in out Generator) return Float is
         Result : Long_Long_Integer;
      begin
         -- Linear Congruential Generator
         Gen.State := (A * Gen.State + C) mod M;
         Result := Gen.State;
         -- Convert to float in range [0.0, 1.0)
         return Float(Result) / Float(M);
      end Random;
      
      function Random_Level (Gen : in out Generator) return Level_Type is
         Level : Level_Type := 0;
         Rand : Float;
      begin
         -- Probabilistic level generation: P^level > random value
         -- This gives us the geometric distribution characteristic of skip lists
         loop
            Rand := Random(Gen);
            exit when Rand >= P or Level = Level_Type(Max_Level - 1);
            Level := Level + 1;
         end loop;
         return Level;
      end Random_Level;
   end Random_Generator;

   -- Global random generator instance
   Gen : Random_Generator.Generator;

   -- Memory deallocation for nodes
   -- Note: This is not SPARK compatible, so we mark procedures using it as SPARK_Mode => Off
   procedure Free is new Ada.Unchecked_Deallocation (Node, Node_Access);

   -- Initialize the skip list
   procedure Initialize (List : out Skip_List_Type) is
      pragma SPARK_Mode (Off);
   begin
      List.Head := new Node'(Key => Element_Type'First, 
                            Value => Element_Type'First,
                            Forward => (others => null));
      List.Current_Level := 0;
      List.Count := 0;
   end Initialize;

   -- Clear the skip list, freeing all memory
   procedure Clear (List : in out Skip_List_Type) is
      pragma SPARK_Mode (Off);
      Current : Node_Access := List.Head;
      Next_Node : Node_Access;
   begin
      -- Free all nodes except the head (which is always present)
      while Current.Forward(0) /= null loop
         Next_Node := Current.Forward(0);
         Current.Forward(0) := Next_Node.Forward(0);
         Free (Next_Node);
      end loop;
      
      -- Reset the head node's forward pointers
      for I in Level_Type loop
         List.Head.Forward(I) := null;
      end loop;
      
      List.Current_Level := 0;
      List.Count := 0;
   end Clear;

   -- Check if the skip list is empty
   function Is_Empty (List : Skip_List_Type) return Boolean is
      use Ada.Containers;
   begin
      return List.Count = Count_Type(0);
   end Is_Empty;

   -- Get the number of elements in the skip list
   function Length (List : Skip_List_Type) return Ada.Containers.Count_Type is
   begin
      return List.Count;
   end Length;

   -- Generate a random level for a new node
   function Generate_Level return Level_Type is
   begin
      return Random_Generator.Random_Level(Gen);
   end Generate_Level;

   -- Set the random seed for deterministic probabilistic behavior
   procedure Set_Random_Seed (Seed : Integer) is
   begin
      Random_Generator.Initialize(Gen, Seed);
   end Set_Random_Seed;

   -- Get the current level of the skip list
   function Current_Level (List : Skip_List_Type) return Level_Type is
   begin
      return List.Current_Level;
   end Current_Level;

   -- Search for a key and return its value
   procedure Search (List   : Skip_List_Type;
                    Key    : Element_Type;
                    Value  : out Element_Type;
                    Found  : out Boolean) is
      Current : Node_Access := List.Head;
      Lvl : Level_Type := List.Current_Level;
   begin
      Found := False;
      -- Start from the highest level and work down
      for Lev in reverse 0 .. List.Current_Level loop
         -- Move forward while the next node's key is less than the search key
         while Current.Forward(Lev) /= null and then 
               Current.Forward(Lev).all.Key < Key loop
            Current := Current.Forward(Lev);
         end loop;
          
         -- If we found the key at this level, return it
         if Current.Forward(Lev) /= null and then 
            Current.Forward(Lev).all.Key = Key then
            Value := Current.Forward(Lev).all.Value;
            Found := True;
            return;
         end if;
      end loop;
      
      -- Key not found
      Found := False;
   end Search;

   -- Check if a key exists in the skip list
   function Contains (List  : Skip_List_Type;
                     Key   : Element_Type) return Boolean is
      Value : Element_Type;
      Found : Boolean;
   begin
      Search(List, Key, Value, Found);
      return Found;
   end Contains;

   -- Get the minimum key in the skip list
   function Min_Key (List : Skip_List_Type) return Element_Type is
   begin
      -- The minimum key is the first element at level 0
      if List.Head.Forward(0) = null then
         raise Empty_List_Error;
      end if;
      return List.Head.Forward(0).all.Key;
   end Min_Key;

   -- Get the maximum key in the skip list
   function Max_Key (List : Skip_List_Type) return Element_Type is
      Current : Node_Access := List.Head;
   begin
      -- Traverse level 0 to find the last element
      while Current.Forward(0) /= null loop
         Current := Current.Forward(0);
      end loop;
      
      if Current = List.Head then
         raise Empty_List_Error;
      end if;
      
      return Current.all.Key;
   end Max_Key;

   -- Insert a key-value pair into the skip list
   procedure Insert (List  : in out Skip_List_Type; 
                    Key    : Element_Type;
                    Value  : Element_Type;
                    Success : out Boolean) is
      pragma SPARK_Mode (Off);
      -- Array to store the update positions for each level
      type Update_Array is array (Level_Type) of Node_Access;
      Update : Update_Array;
      
      Current : Node_Access := List.Head;
      Lvl : Level_Type := List.Current_Level;
      New_Level : Level_Type;
      New_Node : Node_Access;
      
   begin
      -- Check for duplicate key first
      if Contains(List, Key) then
         Success := False;
         return;
      end if;
      
      -- Initialize update array
      for I in Level_Type loop
         Update(I) := List.Head;
      end loop;
      
      -- Find the insertion positions at each level
      while Lvl >= 0 loop
         -- Move forward while the next node's key is less than the insertion key
         while Current.Forward(Lvl) /= null and then 
               Current.Forward(Lvl).all.Key < Key loop
            Current := Current.Forward(Lvl);
         end loop;
          
         -- Store the update position for this level
         Update(Lvl) := Current;
          
         -- Move down to the next level
         Lvl := Lvl - 1;
      end loop;
      
      -- Generate a random level for the new node
      New_Level := Generate_Level;
      
      -- If the new level is higher than the current list level,
      -- update the list's current level and initialize the update array
      if New_Level > List.Current_Level then
         for I in List.Current_Level + 1 .. New_Level loop
            Update(I) := List.Head;
         end loop;
         List.Current_Level := New_Level;
      end if;
      
      -- Create the new node
      New_Node := new Node'(Key => Key, Value => Value, Forward => (others => null));
      
      -- Insert the new node at each level up to its assigned level
      for I in 0 .. New_Level loop
         New_Node.Forward(I) := Update(I).Forward(I);
         Update(I).Forward(I) := New_Node;
      end loop;
      
      -- Increment the count
      List.Count := Ada.Containers.Count_Type'Succ(List.Count);
      
      Success := True;
   end Insert;

   -- Delete a key from the skip list
   procedure Delete (List : in out Skip_List_Type;
                    Key   : Element_Type;
                    Success : out Boolean) is
      pragma SPARK_Mode (Off);
      -- Array to store the update positions for each level
      type Update_Array is array (Level_Type) of Node_Access;
      Update : Update_Array;
      
      Current : Node_Access := List.Head;
      Lvl : Level_Type := List.Current_Level;
      Node_To_Delete : Node_Access;
      
   begin
      -- Initialize update array
      for I in Level_Type loop
         Update(I) := List.Head;
      end loop;
      
      -- Find the node to delete at each level
      while Lvl >= 0 loop
         -- Move forward while the next node's key is less than the deletion key
         while Current.Forward(Lvl) /= null and then 
               Current.Forward(Lvl).all.Key < Key loop
            Current := Current.Forward(Lvl);
         end loop;
          
         -- Store the update position for this level
         Update(Lvl) := Current;
          
         -- Move down to the next level
         Lvl := Lvl - 1;
      end loop;
      
      -- Check if the node exists at level 0
      if Update(0).Forward(0) = null or else Update(0).Forward(0).all.Key /= Key then
         Success := False;
         return;
      end if;
      
      Node_To_Delete := Update(0).Forward(0);
      
      -- Remove the node from each level
      for I in 0 .. List.Current_Level loop
         if Update(I).Forward(I) = Node_To_Delete then
            Update(I).Forward(I) := Node_To_Delete.Forward(I);
         end if;
      end loop;
      
      -- Free the node
      Free(Node_To_Delete);
      
      -- Update the current level if necessary
      -- (if the highest level is now empty, reduce current level)
      while List.Current_Level > 0 and then 
            List.Head.Forward(List.Current_Level) = null loop
         List.Current_Level := List.Current_Level - 1;
      end loop;
      
      -- Decrement the count
      List.Count := Ada.Containers.Count_Type'Pred(List.Count);
      
      Success := True;
   end Delete;

   -- Check if cursor points to an element
   function Has_Element (Position : Cursor) return Boolean is
   begin
      return Position.Node_Ptr /= null;
   end Has_Element;

   -- Get the key at the current cursor position
   function Key (Position : Cursor) return Element_Type is
   begin
      return Position.Node_Ptr.all.Key;
   end Key;

   -- Get the value at the current cursor position
   function Value (Position : Cursor) return Element_Type is
   begin
      return Position.Node_Ptr.all.Value;
   end Value;

   -- Move cursor to the first element
   function First (List : Skip_List_Type) return Cursor is
   begin
      if List.Head.Forward(0) = null then
         return No_Element;
      end if;
      return (Node_Ptr => List.Head.Forward(0));
   end First;

   -- Move cursor to the next element
   function Next (List : Skip_List_Type; Position : Cursor) return Cursor is
   begin
      if Position.Node_Ptr.Forward(0) = null then
         return No_Element;
      end if;
      return (Node_Ptr => Position.Node_Ptr.Forward(0));
   end Next;

begin
   -- Initialize the random generator with a default seed
   -- This ensures deterministic behavior for verification
   Set_Random_Seed(42);
end Skip_List;
