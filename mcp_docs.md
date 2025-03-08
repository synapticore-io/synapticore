# MCP FastMCP Modul Dokumentation

Diese Dokumentation wurde automatisch generiert.

## Modul: mcp.server.fastmcp.exceptions

### Klasse: FastMCPError

**Erbt von:** Exception

**Beschreibung:**

```
Base error for FastMCP.
```


### Klasse: InvalidSignature

**Erbt von:** Exception

**Beschreibung:**

```
Invalid signature for use with FastMCP.
```


### Klasse: ResourceError

**Erbt von:** FastMCPError

**Beschreibung:**

```
Error in resource operations.
```


### Klasse: ToolError

**Erbt von:** FastMCPError

**Beschreibung:**

```
Error in tool operations.
```


### Klasse: ValidationError

**Erbt von:** FastMCPError

**Beschreibung:**

```
Error in validating parameters or return values.
```


## Modul: mcp.server.fastmcp.prompts.base

### Klasse: AssistantMessage

**Erbt von:** Message

**Signatur:** `(content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, *, role: Literal['user', 'assistant'] = 'assistant') -> None`

**Beschreibung:**

```
A message from the assistant.
```

**Methoden:**

#### __init__

**Signatur:** `(self, content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, **kwargs)`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: Message

**Erbt von:** BaseModel

**Signatur:** `(content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, *, role: Literal['user', 'assistant']) -> None`

**Beschreibung:**

```
Base class for all prompt messages.
```

**Methoden:**

#### __init__

**Signatur:** `(self, content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, **kwargs)`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: Prompt

**Erbt von:** BaseModel

**Signatur:** `(*, name: str, description: str | None = None, arguments: list[mcp.server.fastmcp.prompts.base.PromptArgument] | None = None, fn: collections.abc.Callable) -> None`

**Beschreibung:**

```
A prompt template that can be rendered with parameters.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_function

**Signatur:** `(fn: collections.abc.Callable[..., typing.Union[str, mcp.server.fastmcp.prompts.base.Message, dict[str, typing.Any], typing.Sequence[str | mcp.server.fastmcp.prompts.base.Message | dict[str, typing.Any]], typing.Awaitable[typing.Union[str, mcp.server.fastmcp.prompts.base.Message, dict[str, typing.Any], typing.Sequence[str | mcp.server.fastmcp.prompts.base.Message | dict[str, typing.Any]]]]]], name: str | None = None, description: str | None = None) -> 'Prompt'`

**Beschreibung:**

```
Create a Prompt from a function.

The function can return:
- A string (converted to a message)
- A Message object
- A dict (converted to a message)
- A sequence of any of the above
```


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### render

**Signatur:** `(self, arguments: dict[str, typing.Any] | None = None) -> list[mcp.server.fastmcp.prompts.base.Message]`

**Beschreibung:**

```
Render the prompt with arguments.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: PromptArgument

**Erbt von:** BaseModel

**Signatur:** `(*, name: str, description: str | None = None, required: bool = False) -> None`

**Beschreibung:**

```
An argument that can be passed to a prompt.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: UserMessage

**Erbt von:** Message

**Signatur:** `(content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, *, role: Literal['user', 'assistant'] = 'user') -> None`

**Beschreibung:**

```
A message from the user.
```

**Methoden:**

#### __init__

**Signatur:** `(self, content: str | mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource, **kwargs)`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.prompts.manager

### Klasse: PromptManager

**Erbt von:** object

**Signatur:** `(warn_on_duplicate_prompts: bool = True)`

**Beschreibung:**

```
Manages FastMCP prompts.
```

**Methoden:**

#### __init__

**Signatur:** `(self, warn_on_duplicate_prompts: bool = True)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### add_prompt

**Signatur:** `(self, prompt: mcp.server.fastmcp.prompts.base.Prompt) -> mcp.server.fastmcp.prompts.base.Prompt`

**Beschreibung:**

```
Add a prompt to the manager.
```


#### get_prompt

**Signatur:** `(self, name: str) -> mcp.server.fastmcp.prompts.base.Prompt | None`

**Beschreibung:**

```
Get prompt by name.
```


#### list_prompts

**Signatur:** `(self) -> list[mcp.server.fastmcp.prompts.base.Prompt]`

**Beschreibung:**

```
List all registered prompts.
```


#### render_prompt

**Signatur:** `(self, name: str, arguments: dict[str, typing.Any] | None = None) -> list[mcp.server.fastmcp.prompts.base.Message]`

**Beschreibung:**

```
Render a prompt by name with arguments.
```



## Modul: mcp.server.fastmcp.prompts.prompt_manager

### Klasse: PromptManager

**Erbt von:** object

**Signatur:** `(warn_on_duplicate_prompts: bool = True)`

**Beschreibung:**

```
Manages FastMCP prompts.
```

**Methoden:**

#### __init__

**Signatur:** `(self, warn_on_duplicate_prompts: bool = True)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### add_prompt

**Signatur:** `(self, prompt: mcp.server.fastmcp.prompts.base.Prompt) -> mcp.server.fastmcp.prompts.base.Prompt`

**Beschreibung:**

```
Add a prompt to the manager.
```


#### get_prompt

**Signatur:** `(self, name: str) -> mcp.server.fastmcp.prompts.base.Prompt | None`

**Beschreibung:**

```
Get prompt by name.
```


#### list_prompts

**Signatur:** `(self) -> list[mcp.server.fastmcp.prompts.base.Prompt]`

**Beschreibung:**

```
List all registered prompts.
```



## Modul: mcp.server.fastmcp.resources.base

### Klasse: Resource

**Erbt von:** BaseModel, ABC

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: Annotated[str, _PydanticGeneralMetadata(pattern='^[a-zA-Z0-9]+/[a-zA-Z0-9\\-+.]+$')] = 'text/plain') -> None`

**Beschreibung:**

```
Base class for all resources.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str | bytes`

**Beschreibung:**

```
Read the resource content.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.resources.resource_manager

### Klasse: ResourceManager

**Erbt von:** object

**Signatur:** `(warn_on_duplicate_resources: bool = True)`

**Beschreibung:**

```
Manages FastMCP resources.
```

**Methoden:**

#### __init__

**Signatur:** `(self, warn_on_duplicate_resources: bool = True)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### add_resource

**Signatur:** `(self, resource: mcp.server.fastmcp.resources.base.Resource) -> mcp.server.fastmcp.resources.base.Resource`

**Beschreibung:**

```
Add a resource to the manager.

Args:
    resource: A Resource instance to add

Returns:
    The added resource. If a resource with the same URI already exists,
    returns the existing resource.
```


#### add_template

**Signatur:** `(self, fn: Callable, uri_template: str, name: str | None = None, description: str | None = None, mime_type: str | None = None) -> mcp.server.fastmcp.resources.templates.ResourceTemplate`

**Beschreibung:**

```
Add a template from a function.
```


#### get_resource

**Signatur:** `(self, uri: pydantic.networks.AnyUrl | str) -> mcp.server.fastmcp.resources.base.Resource | None`

**Beschreibung:**

```
Get resource by URI, checking concrete resources first, then templates.
```


#### list_resources

**Signatur:** `(self) -> list[mcp.server.fastmcp.resources.base.Resource]`

**Beschreibung:**

```
List all registered resources.
```


#### list_templates

**Signatur:** `(self) -> list[mcp.server.fastmcp.resources.templates.ResourceTemplate]`

**Beschreibung:**

```
List all registered templates.
```



## Modul: mcp.server.fastmcp.resources.templates

### Klasse: ResourceTemplate

**Erbt von:** BaseModel

**Signatur:** `(*, uri_template: str, name: str, description: str | None, mime_type: str = 'text/plain', fn: Callable, parameters: dict) -> None`

**Beschreibung:**

```
A template for dynamically creating resources.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### create_resource

**Signatur:** `(self, uri: str, params: dict[str, typing.Any]) -> mcp.server.fastmcp.resources.base.Resource`

**Beschreibung:**

```
Create a resource from the template with the given parameters.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_function

**Signatur:** `(fn: Callable, uri_template: str, name: str | None = None, description: str | None = None, mime_type: str | None = None) -> 'ResourceTemplate'`

**Beschreibung:**

```
Create a template from a function.
```


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### matches

**Signatur:** `(self, uri: str) -> dict[str, typing.Any] | None`

**Beschreibung:**

```
Check if URI matches template and extract parameters.
```


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.resources.types

### Klasse: BinaryResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: Annotated[str, _PydanticGeneralMetadata(pattern='^[a-zA-Z0-9]+/[a-zA-Z0-9\\-+.]+$')] = 'text/plain', data: bytes) -> None`

**Beschreibung:**

```
A resource that reads from bytes.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> bytes`

**Beschreibung:**

```
Read the binary content.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: DirectoryResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: str = 'application/json', path: pathlib._local.Path, recursive: bool = False, pattern: str | None = None) -> None`

**Beschreibung:**

```
A resource that lists files in a directory.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### list_files

**Signatur:** `(self) -> list[pathlib._local.Path]`

**Beschreibung:**

```
List files in the directory.
```


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str`

**Beschreibung:**

```
Read the directory listing.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`


#### validate_absolute_path

**Signatur:** `(path: pathlib._local.Path) -> pathlib._local.Path`

**Beschreibung:**

```
Ensure path is absolute.
```



### Klasse: FileResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: str = 'text/plain', path: pathlib._local.Path, is_binary: bool = False) -> None`

**Beschreibung:**

```
A resource that reads from a file.

Set is_binary=True to read file as binary data instead of text.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str | bytes`

**Beschreibung:**

```
Read the file content.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_binary_from_mime_type

**Signatur:** `(is_binary: bool, info: pydantic_core.core_schema.ValidationInfo) -> bool`

**Beschreibung:**

```
Set is_binary based on mime_type if not explicitly set.
```


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`


#### validate_absolute_path

**Signatur:** `(path: pathlib._local.Path) -> pathlib._local.Path`

**Beschreibung:**

```
Ensure path is absolute.
```



### Klasse: FunctionResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: Annotated[str, _PydanticGeneralMetadata(pattern='^[a-zA-Z0-9]+/[a-zA-Z0-9\\-+.]+$')] = 'text/plain', fn: collections.abc.Callable[[], typing.Any]) -> None`

**Beschreibung:**

```
A resource that defers data loading by wrapping a function.

The function is only called when the resource is read, allowing for lazy loading
of potentially expensive data. This is particularly useful when listing resources,
as the function won't be called until the resource is actually accessed.

The function can return:
- str for text content (default)
- bytes for binary content
- other types will be converted to JSON
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str | bytes`

**Beschreibung:**

```
Read the resource by calling the wrapped function.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: HttpResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: str = 'application/json', url: str) -> None`

**Beschreibung:**

```
A resource that reads from an HTTP endpoint.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str | bytes`

**Beschreibung:**

```
Read the HTTP content.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: TextResource

**Erbt von:** Resource

**Signatur:** `(*, uri: Annotated[pydantic.networks.AnyUrl, UrlConstraints(max_length=None, allowed_schemes=None, host_required=False, default_host=None, default_port=None, default_path=None)], name: str | None = None, description: str | None = None, mime_type: Annotated[str, _PydanticGeneralMetadata(pattern='^[a-zA-Z0-9]+/[a-zA-Z0-9\\-+.]+$')] = 'text/plain', text: str) -> None`

**Beschreibung:**

```
A resource that reads from a string.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read

**Signatur:** `(self) -> str`

**Beschreibung:**

```
Read the text content.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### set_default_name

**Signatur:** `(name: str | None, info: pydantic_core.core_schema.ValidationInfo) -> str`

**Beschreibung:**

```
Set default name from URI if not provided.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.server

### Klasse: Context

**Erbt von:** BaseModel

**Signatur:** `(*, request_context: mcp.shared.context.RequestContext | None = None, fastmcp: mcp.server.fastmcp.server.FastMCP | None = None) -> None`

**Beschreibung:**

```
Context object providing access to MCP capabilities.

This provides a cleaner interface to MCP's RequestContext functionality.
It gets injected into tool and resource functions that request it via type hints.

To use context in a tool function, add a parameter with the Context type annotation:

```python
@server.tool()
def my_tool(x: int, ctx: Context) -> str:
    # Log messages to the client
    ctx.info(f"Processing {x}")
    ctx.debug("Debug info")
    ctx.warning("Warning message")
    ctx.error("Error message")

    # Report progress
    ctx.report_progress(50, 100)

    # Access resources
    data = ctx.read_resource("resource://data")

    # Get request info
    request_id = ctx.request_id
    client_id = ctx.client_id

    return str(x)
```

The context parameter name can be anything as long as it's annotated with Context.
The context is optional - tools that don't need it can omit the parameter.
```

**Methoden:**

#### __init__

**Signatur:** `(self, *, request_context: mcp.shared.context.RequestContext | None = None, fastmcp: mcp.server.fastmcp.server.FastMCP | None = None, **kwargs: Any)`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### debug

**Signatur:** `(self, message: str, **extra: Any) -> None`

**Beschreibung:**

```
Send a debug log message.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### error

**Signatur:** `(self, message: str, **extra: Any) -> None`

**Beschreibung:**

```
Send an error log message.
```


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### info

**Signatur:** `(self, message: str, **extra: Any) -> None`

**Beschreibung:**

```
Send an info log message.
```


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### log

**Signatur:** `(self, level: Literal['debug', 'info', 'warning', 'error'], message: str, *, logger_name: str | None = None) -> None`

**Beschreibung:**

```
Send a log message to the client.

Args:
    level: Log level (debug, info, warning, error)
    message: Log message
    logger_name: Optional logger name
    **extra: Additional structured data to include
```


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self: 'BaseModel', context: 'Any', /) -> 'None'`

**Beschreibung:**

```
This function is meant to behave like a BaseModel method to initialise private attributes.

It takes context as an argument since that's what pydantic-core passes when calling it.

Args:
    self: The BaseModel instance.
    context: The context.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### read_resource

**Signatur:** `(self, uri: str | pydantic.networks.AnyUrl) -> collections.abc.Iterable[mcp.server.lowlevel.helper_types.ReadResourceContents]`

**Beschreibung:**

```
Read a resource by URI.

Args:
    uri: Resource URI to read

Returns:
    The resource content as either text or bytes
```


#### report_progress

**Signatur:** `(self, progress: float, total: float | None = None) -> None`

**Beschreibung:**

```
Report progress for the current operation.

Args:
    progress: Current progress value e.g. 24
    total: Optional total value e.g. 100
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`


#### warning

**Signatur:** `(self, message: str, **extra: Any) -> None`

**Beschreibung:**

```
Send a warning log message.
```



### Klasse: FastMCP

**Erbt von:** object

**Signatur:** `(name: str | None = None, instructions: str | None = None, **settings: Any)`

**Methoden:**

#### __init__

**Signatur:** `(self, name: str | None = None, instructions: str | None = None, **settings: Any)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### add_prompt

**Signatur:** `(self, prompt: mcp.server.fastmcp.prompts.base.Prompt) -> None`

**Beschreibung:**

```
Add a prompt to the server.

Args:
    prompt: A Prompt instance to add
```


#### add_resource

**Signatur:** `(self, resource: mcp.server.fastmcp.resources.base.Resource) -> None`

**Beschreibung:**

```
Add a resource to the server.

Args:
    resource: A Resource instance to add
```


#### add_tool

**Signatur:** `(self, fn: Callable[..., Any], name: str | None = None, description: str | None = None) -> None`

**Beschreibung:**

```
Add a tool to the server.

The tool function can optionally request a Context object by adding a parameter
with the Context type annotation. See the @tool decorator for examples.

Args:
    fn: The function to register as a tool
    name: Optional name for the tool (defaults to function name)
    description: Optional description of what the tool does
```


#### call_tool

**Signatur:** `(self, name: str, arguments: dict[str, typing.Any]) -> Sequence[mcp.types.TextContent | mcp.types.ImageContent | mcp.types.EmbeddedResource]`

**Beschreibung:**

```
Call a tool by name with arguments.
```


#### get_context

**Signatur:** `(self) -> 'Context'`

**Beschreibung:**

```
Returns a Context object. Note that the context will only be valid
during a request; outside a request, most methods will error.
```


#### get_prompt

**Signatur:** `(self, name: str, arguments: dict[str, typing.Any] | None = None) -> mcp.types.GetPromptResult`

**Beschreibung:**

```
Get a prompt by name with arguments.
```


#### list_prompts

**Signatur:** `(self) -> list[mcp.types.Prompt]`

**Beschreibung:**

```
List all available prompts.
```


#### list_resource_templates

**Signatur:** `(self) -> list[mcp.types.ResourceTemplate]`


#### list_resources

**Signatur:** `(self) -> list[mcp.types.Resource]`

**Beschreibung:**

```
List all available resources.
```


#### list_tools

**Signatur:** `(self) -> list[mcp.types.Tool]`

**Beschreibung:**

```
List all available tools.
```


#### prompt

**Signatur:** `(self, name: str | None = None, description: str | None = None) -> Callable[[Callable[..., Any]], Callable[..., Any]]`

**Beschreibung:**

```
Decorator to register a prompt.

        Args:
            name: Optional name for the prompt (defaults to function name)
            description: Optional description of what the prompt does

        Example:
            @server.prompt()
            def analyze_table(table_name: str) -> list[Message]:
                schema = read_table_schema(table_name)
                return [
                    {
                        "role": "user",
                        "content": f"Analyze this schema:
{schema}"
                    }
                ]

            @server.prompt()
            async def analyze_file(path: str) -> list[Message]:
                content = await read_file(path)
                return [
                    {
                        "role": "user",
                        "content": {
                            "type": "resource",
                            "resource": {
                                "uri": f"file://{path}",
                                "text": content
                            }
                        }
                    }
                ]
        
```


#### read_resource

**Signatur:** `(self, uri: pydantic.networks.AnyUrl | str) -> collections.abc.Iterable[mcp.server.lowlevel.helper_types.ReadResourceContents]`

**Beschreibung:**

```
Read a resource by URI.
```


#### resource

**Signatur:** `(self, uri: str, *, name: str | None = None, description: str | None = None, mime_type: str | None = None) -> Callable[[Callable[..., Any]], Callable[..., Any]]`

**Beschreibung:**

```
Decorator to register a function as a resource.

The function will be called when the resource is read to generate its content.
The function can return:
- str for text content
- bytes for binary content
- other types will be converted to JSON

If the URI contains parameters (e.g. "resource://{param}") or the function
has parameters, it will be registered as a template resource.

Args:
    uri: URI for the resource (e.g. "resource://my-resource" or "resource://{param}")
    name: Optional name for the resource
    description: Optional description of the resource
    mime_type: Optional MIME type for the resource

Example:
    @server.resource("resource://my-resource")
    def get_data() -> str:
        return "Hello, world!"

    @server.resource("resource://my-resource")
    async get_data() -> str:
        data = await fetch_data()
        return f"Hello, world! {data}"

    @server.resource("resource://{city}/weather")
    def get_weather(city: str) -> str:
        return f"Weather for {city}"

    @server.resource("resource://{city}/weather")
    async def get_weather(city: str) -> str:
        data = await fetch_weather(city)
        return f"Weather for {city}: {data}"
```


#### run

**Signatur:** `(self, transport: Literal['stdio', 'sse'] = 'stdio') -> None`

**Beschreibung:**

```
Run the FastMCP server. Note this is a synchronous function.

Args:
    transport: Transport protocol to use ("stdio" or "sse")
```


#### run_sse_async

**Signatur:** `(self) -> None`

**Beschreibung:**

```
Run the server using SSE transport.
```


#### run_stdio_async

**Signatur:** `(self) -> None`

**Beschreibung:**

```
Run the server using stdio transport.
```


#### tool

**Signatur:** `(self, name: str | None = None, description: str | None = None) -> Callable[[Callable[..., Any]], Callable[..., Any]]`

**Beschreibung:**

```
Decorator to register a tool.

Tools can optionally request a Context object by adding a parameter with the
Context type annotation. The context provides access to MCP capabilities like
logging, progress reporting, and resource access.

Args:
    name: Optional name for the tool (defaults to function name)
    description: Optional description of what the tool does

Example:
    @server.tool()
    def my_tool(x: int) -> str:
        return str(x)

    @server.tool()
    def tool_with_context(x: int, ctx: Context) -> str:
        ctx.info(f"Processing {x}")
        return str(x)

    @server.tool()
    async def async_tool(x: int, context: Context) -> str:
        await context.report_progress(50, 100)
        return str(x)
```



### Klasse: Settings

**Erbt von:** BaseSettings, Generic

**Signatur:** `(_case_sensitive: 'bool | None' = None, _nested_model_default_partial_update: 'bool | None' = None, _env_prefix: 'str | None' = None, _env_file: 'DotenvType | None' = PosixPath('.'), _env_file_encoding: 'str | None' = None, _env_ignore_empty: 'bool | None' = None, _env_nested_delimiter: 'str | None' = None, _env_nested_max_split: 'int | None' = None, _env_parse_none_str: 'str | None' = None, _env_parse_enums: 'bool | None' = None, _cli_prog_name: 'str | None' = None, _cli_parse_args: 'bool | list[str] | tuple[str, ...] | None' = None, _cli_settings_source: 'CliSettingsSource[Any] | None' = None, _cli_parse_none_str: 'str | None' = None, _cli_hide_none_type: 'bool | None' = None, _cli_avoid_json: 'bool | None' = None, _cli_enforce_required: 'bool | None' = None, _cli_use_class_docs_for_groups: 'bool | None' = None, _cli_exit_on_error: 'bool | None' = None, _cli_prefix: 'str | None' = None, _cli_flag_prefix_char: 'str | None' = None, _cli_implicit_flags: 'bool | None' = None, _cli_ignore_unknown_args: 'bool | None' = None, _cli_kebab_case: 'bool | None' = None, _secrets_dir: 'PathType | None' = None) -> None`

**Beschreibung:**

```
FastMCP server settings.

All settings can be configured via environment variables with the prefix FASTMCP_.
For example, FASTMCP_DEBUG=true will set debug=True.
```

**Methoden:**

#### __init__

**Signatur:** `(__pydantic_self__, _case_sensitive: 'bool | None' = None, _nested_model_default_partial_update: 'bool | None' = None, _env_prefix: 'str | None' = None, _env_file: 'DotenvType | None' = PosixPath('.'), _env_file_encoding: 'str | None' = None, _env_ignore_empty: 'bool | None' = None, _env_nested_delimiter: 'str | None' = None, _env_nested_max_split: 'int | None' = None, _env_parse_none_str: 'str | None' = None, _env_parse_enums: 'bool | None' = None, _cli_prog_name: 'str | None' = None, _cli_parse_args: 'bool | list[str] | tuple[str, ...] | None' = None, _cli_settings_source: 'CliSettingsSource[Any] | None' = None, _cli_parse_none_str: 'str | None' = None, _cli_hide_none_type: 'bool | None' = None, _cli_avoid_json: 'bool | None' = None, _cli_enforce_required: 'bool | None' = None, _cli_use_class_docs_for_groups: 'bool | None' = None, _cli_exit_on_error: 'bool | None' = None, _cli_prefix: 'str | None' = None, _cli_flag_prefix_char: 'str | None' = None, _cli_implicit_flags: 'bool | None' = None, _cli_ignore_unknown_args: 'bool | None' = None, _cli_kebab_case: 'bool | None' = None, _secrets_dir: 'PathType | None' = None, **values: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### settings_customise_sources

**Signatur:** `(settings_cls: 'type[BaseSettings]', init_settings: 'PydanticBaseSettingsSource', env_settings: 'PydanticBaseSettingsSource', dotenv_settings: 'PydanticBaseSettingsSource', file_secret_settings: 'PydanticBaseSettingsSource') -> 'tuple[PydanticBaseSettingsSource, ...]'`

**Beschreibung:**

```
Define the sources and their order for loading the settings values.

Args:
    settings_cls: The Settings class.
    init_settings: The `InitSettingsSource` instance.
    env_settings: The `EnvSettingsSource` instance.
    dotenv_settings: The `DotEnvSettingsSource` instance.
    file_secret_settings: The `SecretsSettingsSource` instance.

Returns:
    A tuple containing the sources and their order for loading the settings values.
```


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.tools.base

### Klasse: Tool

**Erbt von:** BaseModel

**Signatur:** `(*, fn: Callable, name: str, description: str, parameters: dict, fn_metadata: mcp.server.fastmcp.utilities.func_metadata.FuncMetadata, is_async: bool, context_kwarg: str | None = None) -> None`

**Beschreibung:**

```
Internal tool registration info.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_function

**Signatur:** `(fn: Callable, name: str | None = None, description: str | None = None, context_kwarg: str | None = None) -> 'Tool'`

**Beschreibung:**

```
Create a Tool from a function.
```


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### run

**Signatur:** `(self, arguments: dict, context: 'Context | None' = None) -> Any`

**Beschreibung:**

```
Run the tool with arguments.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.tools.tool_manager

### Klasse: ToolManager

**Erbt von:** object

**Signatur:** `(warn_on_duplicate_tools: bool = True)`

**Beschreibung:**

```
Manages FastMCP tools.
```

**Methoden:**

#### __init__

**Signatur:** `(self, warn_on_duplicate_tools: bool = True)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### add_tool

**Signatur:** `(self, fn: collections.abc.Callable, name: str | None = None, description: str | None = None) -> mcp.server.fastmcp.tools.base.Tool`

**Beschreibung:**

```
Add a tool to the server.
```


#### call_tool

**Signatur:** `(self, name: str, arguments: dict, context: 'Context | None' = None) -> Any`

**Beschreibung:**

```
Call a tool by name with arguments.
```


#### get_tool

**Signatur:** `(self, name: str) -> mcp.server.fastmcp.tools.base.Tool | None`

**Beschreibung:**

```
Get tool by name.
```


#### list_tools

**Signatur:** `(self) -> list[mcp.server.fastmcp.tools.base.Tool]`

**Beschreibung:**

```
List all registered tools.
```



## Modul: mcp.server.fastmcp.utilities.func_metadata

### Klasse: ArgModelBase

**Erbt von:** BaseModel

**Signatur:** `() -> None`

**Beschreibung:**

```
A model representing the arguments to a function.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_dump_one_level

**Signatur:** `(self) -> dict[str, typing.Any]`

**Beschreibung:**

```
Return a dict of the model's fields, one level deep.

That is, sub-models etc are not dumped - they are kept as pydantic models.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



### Klasse: FuncMetadata

**Erbt von:** BaseModel

**Signatur:** `(*, arg_model: Annotated[type[mcp.server.fastmcp.utilities.func_metadata.ArgModelBase], WithJsonSchema(json_schema=None, mode=None)]) -> None`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/models/

A base class for creating Pydantic models.

Attributes:
    __class_vars__: The names of the class variables defined on the model.
    __private_attributes__: Metadata about the private attributes of the model.
    __signature__: The synthesized `__init__` [`Signature`][inspect.Signature] of the model.

    __pydantic_complete__: Whether model building is completed, or if there are still undefined fields.
    __pydantic_core_schema__: The core schema of the model.
    __pydantic_custom_init__: Whether the model has a custom `__init__` function.
    __pydantic_decorators__: Metadata containing the decorators defined on the model.
        This replaces `Model.__validators__` and `Model.__root_validators__` from Pydantic V1.
    __pydantic_generic_metadata__: Metadata for generic models; contains data used for a similar purpose to
        __args__, __origin__, __parameters__ in typing-module generics. May eventually be replaced by these.
    __pydantic_parent_namespace__: Parent namespace of the model, used for automatic rebuilding of models.
    __pydantic_post_init__: The name of the post-init method for the model, if defined.
    __pydantic_root_model__: Whether the model is a [`RootModel`][pydantic.root_model.RootModel].
    __pydantic_serializer__: The `pydantic-core` `SchemaSerializer` used to dump instances of the model.
    __pydantic_validator__: The `pydantic-core` `SchemaValidator` used to validate instances of the model.

    __pydantic_fields__: A dictionary of field names and their corresponding [`FieldInfo`][pydantic.fields.FieldInfo] objects.
    __pydantic_computed_fields__: A dictionary of computed field names and their corresponding [`ComputedFieldInfo`][pydantic.fields.ComputedFieldInfo] objects.

    __pydantic_extra__: A dictionary containing extra values, if [`extra`][pydantic.config.ConfigDict.extra]
        is set to `'allow'`.
    __pydantic_fields_set__: The names of fields explicitly set during instantiation.
    __pydantic_private__: Values of private attributes set on the model instance.
```

**Methoden:**

#### __init__

**Signatur:** `(self, /, **data: 'Any') -> 'None'`

**Beschreibung:**

```
Create a new model by parsing and validating input data from keyword arguments.

Raises [`ValidationError`][pydantic_core.ValidationError] if the input data cannot be
validated to form a valid model.

`self` is explicitly positional-only to allow `self` as a field name.
```


#### call_fn_with_arg_validation

**Signatur:** `(self, fn: collections.abc.Callable[..., typing.Any] | collections.abc.Awaitable[typing.Any], fn_is_async: bool, arguments_to_validate: dict[str, typing.Any], arguments_to_pass_directly: dict[str, typing.Any] | None) -> Any`

**Beschreibung:**

```
Call the given function with arguments validated and injected.

Arguments are first attempted to be parsed from JSON, then validated against
the argument model, before being passed to the function.
```


#### construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`


#### copy

**Signatur:** `(self, *, include: 'AbstractSetIntStr | MappingIntStrAny | None' = None, exclude: 'AbstractSetIntStr | MappingIntStrAny | None' = None, update: 'Dict[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Returns a copy of the model.

!!! warning "Deprecated"
    This method is now deprecated; use `model_copy` instead.

If you need `include` or `exclude`, use:

```python {test="skip" lint="skip"}
data = self.model_dump(include=include, exclude=exclude, round_trip=True)
data = {**data, **(update or {})}
copied = self.model_validate(data)
```

Args:
    include: Optional set or mapping specifying which fields to include in the copied model.
    exclude: Optional set or mapping specifying which fields to exclude in the copied model.
    update: Optional dictionary of field-value pairs to override field values in the copied model.
    deep: If True, the values of fields that are Pydantic models will be deep-copied.

Returns:
    A copy of the model with included, excluded and updated fields as specified.
```


#### dict

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False) -> 'Dict[str, Any]'`


#### from_orm

**Signatur:** `(obj: 'Any') -> 'Self'`


#### json

**Signatur:** `(self, *, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, encoder: 'Callable[[Any], Any] | None' = PydanticUndefined, models_as_dict: 'bool' = PydanticUndefined, **dumps_kwargs: 'Any') -> 'str'`


#### model_construct

**Signatur:** `(_fields_set: 'set[str] | None' = None, **values: 'Any') -> 'Self'`

**Beschreibung:**

```
Creates a new instance of the `Model` class with validated data.

Creates a new model setting `__dict__` and `__pydantic_fields_set__` from trusted or pre-validated data.
Default values are respected, but no other validation is performed.

!!! note
    `model_construct()` generally respects the `model_config.extra` setting on the provided model.
    That is, if `model_config.extra == 'allow'`, then all extra passed values are added to the model instance's `__dict__`
    and `__pydantic_extra__` fields. If `model_config.extra == 'ignore'` (the default), then all extra passed values are ignored.
    Because no validation is performed with a call to `model_construct()`, having `model_config.extra == 'forbid'` does not result in
    an error if extra values are passed, but they will be ignored.

Args:
    _fields_set: A set of field names that were originally explicitly set during instantiation. If provided,
        this is directly used for the [`model_fields_set`][pydantic.BaseModel.model_fields_set] attribute.
        Otherwise, the field names from the `values` argument will be used.
    values: Trusted or pre-validated data dictionary.

Returns:
    A new instance of the `Model` class with validated data.
```


#### model_copy

**Signatur:** `(self, *, update: 'Mapping[str, Any] | None' = None, deep: 'bool' = False) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#model_copy

Returns a copy of the model.

Args:
    update: Values to change/add in the new model. Note: the data is not validated
        before creating the new model. You should trust this data.
    deep: Set to `True` to make a deep copy of the model.

Returns:
    New model instance.
```


#### model_dump

**Signatur:** `(self, *, mode: "Literal['json', 'python'] | str" = 'python', include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'dict[str, Any]'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump

Generate a dictionary representation of the model, optionally specifying which fields to include or exclude.

Args:
    mode: The mode in which `to_python` should run.
        If mode is 'json', the output will only contain JSON serializable types.
        If mode is 'python', the output may contain non-JSON-serializable Python objects.
    include: A set of fields to include in the output.
    exclude: A set of fields to exclude from the output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to use the field's alias in the dictionary key if defined.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A dictionary representation of the model.
```


#### model_dump_json

**Signatur:** `(self, *, indent: 'int | None' = None, include: 'IncEx | None' = None, exclude: 'IncEx | None' = None, context: 'Any | None' = None, by_alias: 'bool' = False, exclude_unset: 'bool' = False, exclude_defaults: 'bool' = False, exclude_none: 'bool' = False, round_trip: 'bool' = False, warnings: "bool | Literal['none', 'warn', 'error']" = True, serialize_as_any: 'bool' = False) -> 'str'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/serialization/#modelmodel_dump_json

Generates a JSON representation of the model using Pydantic's `to_json` method.

Args:
    indent: Indentation to use in the JSON output. If None is passed, the output will be compact.
    include: Field(s) to include in the JSON output.
    exclude: Field(s) to exclude from the JSON output.
    context: Additional context to pass to the serializer.
    by_alias: Whether to serialize using field aliases.
    exclude_unset: Whether to exclude fields that have not been explicitly set.
    exclude_defaults: Whether to exclude fields that are set to their default value.
    exclude_none: Whether to exclude fields that have a value of `None`.
    round_trip: If True, dumped values should be valid as input for non-idempotent types such as Json[T].
    warnings: How to handle serialization errors. False/"none" ignores them, True/"warn" logs errors,
        "error" raises a [`PydanticSerializationError`][pydantic_core.PydanticSerializationError].
    serialize_as_any: Whether to serialize fields with duck-typing serialization behavior.

Returns:
    A JSON string representation of the model.
```


#### model_json_schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', schema_generator: 'type[GenerateJsonSchema]' = <class 'pydantic.json_schema.GenerateJsonSchema'>, mode: 'JsonSchemaMode' = 'validation') -> 'dict[str, Any]'`

**Beschreibung:**

```
Generates a JSON schema for a model class.

Args:
    by_alias: Whether to use attribute aliases or not.
    ref_template: The reference template.
    schema_generator: To override the logic used to generate the JSON schema, as a subclass of
        `GenerateJsonSchema` with your desired modifications
    mode: The mode in which to generate the schema.

Returns:
    The JSON schema for the given model class.
```


#### model_parametrized_name

**Signatur:** `(params: 'tuple[type[Any], ...]') -> 'str'`

**Beschreibung:**

```
Compute the class name for parametrizations of generic classes.

This method can be overridden to achieve a custom naming scheme for generic BaseModels.

Args:
    params: Tuple of types of the class. Given a generic class
        `Model` with 2 type variables and a concrete model `Model[str, int]`,
        the value `(str, int)` would be passed to `params`.

Returns:
    String representing the new class where `params` are passed to `cls` as type variables.

Raises:
    TypeError: Raised when trying to generate concrete names for non-generic models.
```


#### model_post_init

**Signatur:** `(self, _BaseModel__context: 'Any') -> 'None'`

**Beschreibung:**

```
Override this method to perform additional initialization after `__init__` and `model_construct`.
This is useful if you want to do some validation that requires the entire model to be initialized.
```


#### model_rebuild

**Signatur:** `(*, force: 'bool' = False, raise_errors: 'bool' = True, _parent_namespace_depth: 'int' = 2, _types_namespace: 'MappingNamespace | None' = None) -> 'bool | None'`

**Beschreibung:**

```
Try to rebuild the pydantic-core schema for the model.

This may be necessary when one of the annotations is a ForwardRef which could not be resolved during
the initial attempt to build the schema, and automatic rebuilding fails.

Args:
    force: Whether to force the rebuilding of the model schema, defaults to `False`.
    raise_errors: Whether to raise errors, defaults to `True`.
    _parent_namespace_depth: The depth level of the parent namespace, defaults to 2.
    _types_namespace: The types namespace, defaults to `None`.

Returns:
    Returns `None` if the schema is already "complete" and rebuilding was not required.
    If rebuilding _was_ required, returns `True` if rebuilding was successful, otherwise `False`.
```


#### model_validate

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, from_attributes: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate a pydantic model instance.

Args:
    obj: The object to validate.
    strict: Whether to enforce types strictly.
    from_attributes: Whether to extract data from object attributes.
    context: Additional context to pass to the validator.

Raises:
    ValidationError: If the object could not be validated.

Returns:
    The validated model instance.
```


#### model_validate_json

**Signatur:** `(json_data: 'str | bytes | bytearray', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Usage docs: https://docs.pydantic.dev/2.10/concepts/json/#json-parsing

Validate the given JSON data against the Pydantic model.

Args:
    json_data: The JSON data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.

Raises:
    ValidationError: If `json_data` is not a JSON string or the object could not be validated.
```


#### model_validate_strings

**Signatur:** `(obj: 'Any', *, strict: 'bool | None' = None, context: 'Any | None' = None) -> 'Self'`

**Beschreibung:**

```
Validate the given object with string data against the Pydantic model.

Args:
    obj: The object containing string data to validate.
    strict: Whether to enforce types strictly.
    context: Extra variables to pass to the validator.

Returns:
    The validated Pydantic model.
```


#### parse_file

**Signatur:** `(path: 'str | Path', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### parse_obj

**Signatur:** `(obj: 'Any') -> 'Self'`


#### parse_raw

**Signatur:** `(b: 'str | bytes', *, content_type: 'str | None' = None, encoding: 'str' = 'utf8', proto: 'DeprecatedParseProtocol | None' = None, allow_pickle: 'bool' = False) -> 'Self'`


#### pre_parse_json

**Signatur:** `(self, data: dict[str, typing.Any]) -> dict[str, typing.Any]`

**Beschreibung:**

```
Pre-parse data from JSON.

Return a dict with same keys as input but with values parsed from JSON
if appropriate.

This is to handle cases like `["a", "b", "c"]` being passed in as JSON inside
a string rather than an actual list. Claude desktop is prone to this - in fact
it seems incapable of NOT doing this. For sub-models, it tends to pass
dicts (JSON objects) as JSON strings, which can be pre-parsed here.
```


#### schema

**Signatur:** `(by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}') -> 'Dict[str, Any]'`


#### schema_json

**Signatur:** `(*, by_alias: 'bool' = True, ref_template: 'str' = '#/$defs/{model}', **dumps_kwargs: 'Any') -> 'str'`


#### update_forward_refs

**Signatur:** `(**localns: 'Any') -> 'None'`


#### validate

**Signatur:** `(value: 'Any') -> 'Self'`



## Modul: mcp.server.fastmcp.utilities.types

### Klasse: Image

**Erbt von:** object

**Signatur:** `(path: str | pathlib._local.Path | None = None, data: bytes | None = None, format: str | None = None)`

**Beschreibung:**

```
Helper class for returning images from tools.
```

**Methoden:**

#### __init__

**Signatur:** `(self, path: str | pathlib._local.Path | None = None, data: bytes | None = None, format: str | None = None)`

**Beschreibung:**

```
Initialize self.  See help(type(self)) for accurate signature.
```


#### to_image_content

**Signatur:** `(self) -> mcp.types.ImageContent`

**Beschreibung:**

```
Convert to MCP ImageContent.
```



