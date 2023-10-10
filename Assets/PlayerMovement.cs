using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public Transform pivotPoint; // The pivot point around which the object will rotate
    public float radius = 2.0f; // The radius of the circle
    public float rotationSpeed = 60.0f; // The speed of rotation in degrees per second

    private Vector3 centerPosition;
    private float angle = 0.0f;

    private void Start()
    {
        if (pivotPoint == null)
        {
            Debug.LogError("Please assign a pivot point to the script!");
            enabled = false; // Disable the script if the pivot point is not assigned
        }
        else
        {
            centerPosition = pivotPoint.position;
        }
    }

    private void Update()
    {
        // Calculate the new position based on the circular motion
        angle += rotationSpeed * Time.deltaTime;
        float x = centerPosition.x + Mathf.Cos(angle * Mathf.Deg2Rad) * radius;
        float y = centerPosition.y;
        float z = centerPosition.z + Mathf.Sin(angle * Mathf.Deg2Rad) * radius;

        // Update the GameObject's position
        transform.position = new Vector3(x, y, z);

        // Calculate the tangent direction
        Vector3 tangentDirection = new Vector3(-Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));

        // Rotate the GameObject to align with the tangent direction
        transform.rotation = Quaternion.LookRotation(tangentDirection, Vector3.up);
    }
}
