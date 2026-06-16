# Skip List Implementation in Ada SPARK

A probabilistic skip list data structure implementation in Ada with SPARK formal verification support. Skip lists provide expected O(log n) search, insert, and delete operations through probabilistic level assignment, making them an excellent alternative to balanced trees for verification purposes.

## Features

- **Probabilistic Level Assignment**: Uses geometric distribution (P = 0.5) for node levels
- **Deterministic Behavior**: Fixed random seed (default: 42) ensures reproducible results for verification
- **Full SPARK Support**: Core data structures and simple operations are SPARK-verified
- **Complete API**: Insert, Search, Delete, Contains, Min/Max Key, Iteration
- **Memory Management**: Proper allocation and deallocation with `Ada.Unchecked_Deallocation`

## Project Structure

- `skip_list.ads` - Package specification with type definitions and contracts
- `skip_list.adb` - Package body with implementation
- `skip_list.gpr` - GNAT project file for compilation
- `test_skip_list.adb` - Comprehensive test program

## Quick Start

### Compilation

```bash
# Compile with GNAT
gnatmake -P skip_list.gpr

# Compile with SPARK verification (level 4)
gnatprove -P skip_list.gpr --level=4
```

### Running Tests

```bash
# Compile and run the test program
gnatmake test_skip_list.adb -P skip_list.gpr
./test_skip_list
```

## API Reference

### Types

```ada
-- Element type (can be customized)
type Element_Type is range Integer'First .. Integer'Last;

-- Skip list type
type Skip_List_Type is tagged private;

-- Cursor for iteration
type Cursor is private;

-- No element cursor
No_Element : constant Cursor;
```

### Initialization

```ada
-- Initialize an empty skip list
procedure Initialize (List : out Skip_List_Type);

-- Clear the skip list, freeing all memory
procedure Clear (List : in out Skip_List_Type);

-- Set random seed for deterministic behavior
procedure Set_Random_Seed (Seed : Integer);
```

### Query Operations

```ada
-- Check if the skip list is empty
function Is_Empty (List : Skip_List_Type) return Boolean;

-- Get the number of elements
function Length (List : Skip_List_Type) return Ada.Containers.Count_Type;

-- Get current level (highest non-empty level)
function Current_Level (List : Skip_List_Type) return Level_Type;
```

### Data Operations

```ada
-- Insert a key-value pair
procedure Insert (List  : in out Skip_List_Type;
                 Key    : Element_Type;
                 Value  : Element_Type;
                 Success : out Boolean);

-- Search for a key
procedure Search (List   : in out Skip_List_Type;
                 Key    : Element_Type;
                 Value  : out Element_Type;
                 Found  : out Boolean);

-- Delete a key
procedure Delete (List : in out Skip_List_Type;
                 Key   : Element_Type;
                 Success : out Boolean);

-- Check if key exists
procedure Contains (List  : in out Skip_List_Type;
                   Key   : Element_Type;
                   Result : out Boolean);

-- Get minimum key
procedure Min_Key (List : in out Skip_List_Type;
                  Result : out Element_Type);

-- Get maximum key
procedure Max_Key (List : in out Skip_List_Type;
                  Result : out Element_Type);
```

### Iteration

```ada
-- Check if cursor has an element
function Has_Element (Position : Cursor) return Boolean;

-- Get key at cursor position
function Key (Position : Cursor) return Element_Type
  with Pre => Has_Element(Position);

-- Get value at cursor position
function Value (Position : Cursor) return Element_Type
  with Pre => Has_Element(Position);

-- Get first element
procedure First (List : in out Skip_List_Type;
                Result : out Cursor);

-- Get next element
procedure Next (List : in out Skip_List_Type;
               Position : in out Cursor;
               Result : out Cursor);
```

## SPARK Verification Status

### Verified Components (SPARK Mode On)

- Type definitions (`Skip_List_Type`, `Cursor`, `Node`, etc.)
- Simple query functions (`Is_Empty`, `Length`, `Current_Level`)
- Basic data structure invariants

### Non-Verified Components (SPARK Mode Off)

The following procedures use features not fully supported by SPARK's borrow checker:

- `Initialize` - Uses dynamic allocation (`new`)
- `Clear` - Uses deallocation (`Free`)
- `Insert` - Uses dynamic allocation
- `Delete` - Uses deallocation
- `Search`, `Contains`, `Min_Key`, `Max_Key`, `First`, `Next` - Access access components
- `Random_Generator`, `Generate_Level`, `Set_Random_Seed` - Use `Float` type

**Note**: These components are marked with `pragma SPARK_Mode (Off)` but are still correct and safe Ada code.

## Implementation Details

### Skip List Parameters

```ada
Max_Level : constant Positive := 32;  -- Maximum level
P : constant := 0.5;                    -- Probability factor
```

### Node Structure

Each node contains:
- `Key`: Element_Type
- `Value`: Element_Type  
- `Forward`: Array of forward pointers (one per level)

### Random Number Generation

Uses a Linear Congruential Generator (LCG) for deterministic probabilistic behavior.

## Usage Example

```ada
with Skip_List;

procedure Example is
   List : Skip_List.Skip_List_Type;
   Success, Found : Boolean;
   Value : Skip_List.Element_Type;
   Cursor_Pos : Skip_List.Cursor;
begin
   Skip_List.Initialize(List);
   
   -- Insert elements
   Skip_List.Insert(List, 10, 100, Success);
   Skip_List.Insert(List, 20, 200, Success);
   
   -- Search
   Skip_List.Search(List, 10, Value, Found);
   
   -- Iterate
   Skip_List.First(List, Cursor_Pos);
   while Skip_List.Has_Element(Cursor_Pos) loop
      -- Process Skip_List.Key(Cursor_Pos), Skip_List.Value(Cursor_Pos)
      Skip_List.Next(List, Cursor_Pos, Cursor_Pos);
   end loop;
   
   Skip_List.Clear(List);
end Example;
```

## Verification

```bash
# Full verification at level 4
gnatprove -P skip_list.gpr --level=4

# Generate HTML report
gnatprove -P skip_list.gpr --level=4 --report=html
```

## Performance

- **Search**: O(log n) expected
- **Insert**: O(log n) expected
- **Delete**: O(log n) expected
- **Space**: O(n) expected

## Version History

- **0.30**: Add preconditions to Key and Value functions
- **0.29**: Mark procedures using access components as SPARK_Mode Off
- **0.28**: Convert Min_Key to procedure for SPARK
- **0.27**: Fix borrow checker by using in out mode consistently
- **0.26**: Fix Contains call in Insert procedure
- **0.25**: Convert Contains from function to procedure
- **0.24**: Fix SPARK borrow checker issues
- **0.23**: Fix SPARK parameter passing and Global aspects
- **0.22**: Convert functions to procedures for SPARK compatibility
- **0.21**: Fix SPARK writability and termination issues
- **0.20**: Fix SPARK global state and access type equality issues
- **0.19**: Convert Insert and Delete from functions to procedures
- **0.18**: Re-enable SPARK mode with selective SPARK_Mode Off pragmas
- **0.16**: Fix Count_Type arithmetic and implicit dereference warnings

## License

Provided as-is for educational and verification purposes.

## References

- [Skip List Wikipedia](https://en.wikipedia.org/wiki/Skip_list)
- [Ada SPARK Documentation](https://docs.adacore.com/spark2014-docs/html/lrm/)
