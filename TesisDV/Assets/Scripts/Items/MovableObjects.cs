using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovableObjects : Item
{
    public bool IsMoving;
    public Player OwnerPlayer;
    public Vector3 currentDirection;

    // Start is called before the first frame update
    void Start()
    {
        currentDirection = Vector3.zero;
    }

    // Update is called once per frame
    void Update()
    {
        if (IsMoving) 
        {
            Debug.Log("Player's Velocity:" + ClampedPlayerVelocity());
            var directionForward = OwnerPlayer.gameObject.transform.forward;
            var directionRight = OwnerPlayer.gameObject.transform.forward;
            if (directionForward.z > 0) 
            {
                currentDirection = directionForward;
                currentDirection.z += ClampedPlayerVelocity() * Time.deltaTime;
            }
            else if (directionForward.z < 0)
            {
                currentDirection = -directionForward;
                currentDirection.z += ClampedPlayerVelocity() * Time.deltaTime;
            }

            if (directionRight.z > 0) 
            {
                currentDirection = directionRight;
                currentDirection.x += ClampedPlayerVelocity() * Time.deltaTime;
            }
            else if (directionRight.z < 0) 
            {
                currentDirection = -directionRight;
                currentDirection.x -= ClampedPlayerVelocity() * Time.deltaTime;
            }

            transform.position += currentDirection;
        }
    }

    public float ClampedPlayerVelocity() 
    {
        return OwnerPlayer.GetVelocity().magnitude * 0.01f;
    }
}
