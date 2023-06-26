"""Utility functions for Terraform."""

from typing import Any, Dict, List, Optional

import python_terraform

from mlstacks.models.component import Component
from mlstacks.models.stack import Stack
from mlstacks.utils.yaml_utils import load_stack_yaml


class TerraformRunner:
    """Terraform runner."""

    def __init__(self, tf_recipe_path: str) -> None:
        """Initialize Terraform runner.

        Args:
            tf_recipe_path: The path to the Terraform recipe.
        """
        self.tf_recipe_path = tf_recipe_path

        self.client = python_terraform.Terraform(
            working_dir=self.tf_recipe_path,
        )


def parse_component_variables(
    components: List[Component],
) -> Dict[str, Optional[str]]:
    """Parse component variables.

    Args:
        components: The components of the stack.

    Returns:
        The component variables.
    """
    component_variables = {}
    for component in components:
        if (
            component.component_type == "artifact_store"
            and component.metadata.config
        ):
            component_variables["bucket_name"] = component.metadata.config.get(
                "path",
            )
            component_variables["enable_artifact_store"] = "true"
        # extract the logic for each different component type
        # add those variables to the component_variables dict

    return component_variables


def parse_tf_vars(stack: Stack) -> Dict[str, Any]:
    """Parse Terraform variables.

    Args:
        stack: The stack.

    Returns:
        The Terraform variables.
    """
    tf_vars = {
        "region": stack.default_region,
        "tags": stack.default_tags,
    }
    # update the dict with the component variables
    tf_vars.update(parse_component_variables(stack.components))
    return tf_vars


def deploy_stack(stack_path: str) -> None:
    """Deploy stack.

    Args:
        stack_path: The path to the stack.
    """
    stack = load_stack_yaml(stack_path)
    tf_vars = parse_tf_vars(stack)

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    ret_code, _, _ = tfr.client.init(capture_output=False)

    tfr.client.apply(
        var=tf_vars,
        input=False,
        capture_output=False,
        raise_on_error=True,
        refresh=False,
    )


def destroy_stack(stack_path: str) -> None:
    """Destroy stack.

    Args:
        stack_path: The path to the stack.
    """
    stack = load_stack_yaml(stack_path)
    tf_vars = parse_tf_vars(stack)

    tf_recipe_path = f"terraform/{stack.provider}-modular"

    tfr = TerraformRunner(tf_recipe_path)
    ret_code, _, _ = tfr.client.init(capture_output=False)

    tfr.client.destroy(
        var=tf_vars,
        capture_output=False,
        raise_on_error=True,
        force=python_terraform.IsNotFlagged,
        refresh=False,
    )
