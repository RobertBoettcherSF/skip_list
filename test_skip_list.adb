--  test_skip_list.adb
--  
--  Test program for Skip List implementation
--  
--  Version: 0.16
--  Author: Vibe Code Agent
--  Date: 2024

with Ada.Text_IO;
with Skip_List;

procedure Test_Skip_List is
   -- Use Skip_List package
   use Skip_List;
   
   -- Test list
   List : Skip_List_Type;
   
   -- Test variables
   Success : Boolean;
   Value : Element_Type;
   Cursor_Pos : Cursor;
   
begin
   Ada.Text_IO.Put_Line("=== Skip List Test Program ===");
   
   -- Initialize the list
   Initialize(List);
   Ada.Text_IO.Put_Line("List initialized.");
   
   -- Test Is_Empty on empty list
   if Is_Empty(List) then
      Ada.Text_IO.Put_Line("✓ List is empty (correct).");
   else
      Ada.Text_IO.Put_Line("✗ List is not empty (incorrect).");
   end if;
   
   -- Test Length on empty list
   if Length(List) = 0 then
      Ada.Text_IO.Put_Line("✓ Length is 0 (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Length is not 0 (incorrect).");
   end if;
   
   -- Test inserting elements
   Ada.Text_IO.Put_Line("\n--- Inserting elements ---");
   
   Insert(List, 10, 100, Success);
   if Success then
      Ada.Text_IO.Put_Line("✓ Inserted (10, 100).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to insert (10, 100).");
   end if;
   
   Insert(List, 20, 200, Success);
   if Success then
      Ada.Text_IO.Put_Line("✓ Inserted (20, 200).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to insert (20, 200).");
   end if;
   
   Insert(List, 5, 50, Success);
   if Success then
      Ada.Text_IO.Put_Line("✓ Inserted (5, 50).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to insert (5, 50).");
   end if;
   
   Insert(List, 15, 150, Success);
   if Success then
      Ada.Text_IO.Put_Line("✓ Inserted (15, 150).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to insert (15, 150).");
   end if;
   
   -- Test duplicate insertion
   Insert(List, 10, 999, Success);
   if not Success then
      Ada.Text_IO.Put_Line("✓ Duplicate insertion rejected (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Duplicate insertion accepted (incorrect).");
   end if;
   
   -- Test Length
   if Length(List) = 4 then
      Ada.Text_IO.Put_Line("✓ Length is 4 (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Length is " & Length(List)'Image & " (incorrect).");
   end if;
   
   -- Test Is_Empty
   if not Is_Empty(List) then
      Ada.Text_IO.Put_Line("✓ List is not empty (correct).");
   else
      Ada.Text_IO.Put_Line("✗ List is empty (incorrect).");
   end if;
   
   -- Test Contains
   Ada.Text_IO.Put_Line("\n--- Testing Contains ---");
   if Contains(List, 10) then
      Ada.Text_IO.Put_Line("✓ Contains 10 (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Does not contain 10 (incorrect).");
   end if;
   
   if Contains(List, 99) then
      Ada.Text_IO.Put_Line("✗ Contains 99 (incorrect).");
   else
      Ada.Text_IO.Put_Line("✓ Does not contain 99 (correct).");
   end if;
   
   -- Test Search
   Ada.Text_IO.Put_Line("\n--- Testing Search ---");
   Search(List, 10, Value, Success);
   if Success and Value = 100 then
      Ada.Text_IO.Put_Line("✓ Found (10, 100) (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to find (10, 100) (incorrect).");
   end if;
   
   Search(List, 20, Value, Success);
   if Success and Value = 200 then
      Ada.Text_IO.Put_Line("✓ Found (20, 200) (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Failed to find (20, 200) (incorrect).");
   end if;
   
   -- Test Min_Key and Max_Key
   Ada.Text_IO.Put_Line("\n--- Testing Min/Max Key ---");
   if Min_Key(List) = 5 then
      Ada.Text_IO.Put_Line("✓ Min_Key is 5 (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Min_Key is " & Min_Key(List)'Image & " (incorrect).");
   end if;
   
   Max_Key(List, Value);
   if Value = 20 then
      Ada.Text_IO.Put_Line("✓ Max_Key is 20 (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Max_Key is " & Value'Image & " (incorrect).");
   end if;
   
   -- Test Iterator
   Ada.Text_IO.Put_Line("\n--- Testing Iterator ---");
   First(List, Cursor_Pos);
   if Has_Element(Cursor_Pos) then
      Ada.Text_IO.Put_Line("✓ First element exists.");
      Ada.Text_IO.Put("  Key: ");
      Ada.Text_IO.Put(Key(Cursor_Pos)'Image);
      Ada.Text_IO.Put(", Value: ");
      Ada.Text_IO.Put_Line(Value(Cursor_Pos)'Image);
   else
      Ada.Text_IO.Put_Line("✗ No first element (incorrect).");
   end if;
   
   -- Iterate through all elements
   Ada.Text_IO.Put_Line("  All elements in order:");
   First(List, Cursor_Pos);
   while Has_Element(Cursor_Pos) loop
      Ada.Text_IO.Put("    (");
      Ada.Text_IO.Put(Key(Cursor_Pos)'Image);
      Ada.Text_IO.Put(", ");
      Ada.Text_IO.Put(Value(Cursor_Pos)'Image);
      Ada.Text_IO.Put_Line(")");
      Next(List, Cursor_Pos, Cursor_Pos);
   end loop;
   
   -- Test Delete
   Ada.Text_IO.Put_Line("\n--- Testing Delete ---");
   Delete(List, 15, Success);
   if Success then
      Ada.Text_IO.Put_Line("✓ Deleted key 15.");
   else
      Ada.Text_IO.Put_Line("✗ Failed to delete key 15.");
   end if;
   
   if Length(List) = 3 then
      Ada.Text_IO.Put_Line("✓ Length is 3 after deletion (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Length is " & Length(List)'Image & " after deletion (incorrect).");
   end if;
   
   if not Contains(List, 15) then
      Ada.Text_IO.Put_Line("✓ Key 15 no longer in list (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Key 15 still in list (incorrect).");
   end if;
   
   -- Test deleting non-existent key
   Delete(List, 99, Success);
   if not Success then
      Ada.Text_IO.Put_Line("✓ Delete of non-existent key 99 rejected (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Delete of non-existent key 99 accepted (incorrect).");
   end if;
   
   -- Test Clear
   Ada.Text_IO.Put_Line("\n--- Testing Clear ---");
   Clear(List);
   if Is_Empty(List) then
      Ada.Text_IO.Put_Line("✓ List is empty after Clear (correct).");
   else
      Ada.Text_IO.Put_Line("✗ List is not empty after Clear (incorrect).");
   end if;
   
   if Length(List) = 0 then
      Ada.Text_IO.Put_Line("✓ Length is 0 after Clear (correct).");
   else
      Ada.Text_IO.Put_Line("✗ Length is not 0 after Clear (incorrect).");
   end if;
   
   -- Test deterministic behavior with Set_Random_Seed
   Ada.Text_IO.Put_Line("\n--- Testing Deterministic Behavior ---");
   Set_Random_Seed(42);
   Initialize(List);
   
   -- Insert some elements
   Insert(List, 1, 10);
   Insert(List, 2, 20);
   Insert(List, 3, 30);
   
   -- Get current level (should be deterministic with seed 42)
   Ada.Text_IO.Put("  Current level with seed 42: ");
   Ada.Text_IO.Put_Line(Current_Level(List)'Image);
   
   Ada.Text_IO.Put_Line("\n=== All tests completed ===");
   
exception
   when Empty_List_Error =>
      Ada.Text_IO.Put_Line("✗ Empty_List_Error exception raised.");
   when Duplicate_Key_Error =>
      Ada.Text_IO.Put_Line("✗ Duplicate_Key_Error exception raised.");
   when others =>
      Ada.Text_IO.Put_Line("✗ Unexpected exception: " & Ada.Exceptions.Exception_Name(Ada.Exceptions.Last_Exception) & ": " & 
                          Ada.Exceptions.Exception_Message(Ada.Exceptions.Last_Exception));
end Test_Skip_List;
