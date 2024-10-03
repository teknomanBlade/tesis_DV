using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovableObjects : Item
{
    public bool IsMoving;
    public Player OwnerPlayer;
    public Vector3 currentDirection;
    public float maxSpeed;
    public float maxForce;
    public float seekWeight;
    private Vector3 _velocity;
    // Start is called before the first frame update
    void Start()
    {
        currentDirection = Vector3.zero;
    }

    // Update is called once per frame
    void Update()
    {
        //Debug.Log("DISTANCE TO PLAYER: " + Vector3.Distance(transform.position, OwnerPlayer.transform.position));
        if (IsMoving && Vector3.Distance(transform.position, OwnerPlayer.transform.position) < 3f) 
        {
            ApplyForce(Seek(OwnerPlayer.transform.position) * seekWeight);
            _velocity.y = 0f;
            transform.position += _velocity * Time.deltaTime;
        }
    }

    Vector3 Seek(Vector3 target)
    {
        Vector3 desired = (target - transform.position).normalized * maxSpeed;
        Vector3 steering = Vector3.ClampMagnitude(desired - _velocity, maxForce / 10);
        return steering;
    }

    void ApplyForce(Vector3 force)
    {
        _velocity += Vector3.ClampMagnitude(force, maxSpeed); //clampear si necesario
    }
}
