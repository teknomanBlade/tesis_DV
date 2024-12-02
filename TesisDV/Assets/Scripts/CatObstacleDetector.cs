using UnityEngine;

public class CatObstacleDetector : MonoBehaviour
{
    [SerializeField] private Cat _myOwner;

    void OnTriggerEnter(Collider other)
    {
        var door = other.GetComponent<Door>();

        if (door && !door.GetDoorStatus())
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            _myOwner.OnDoorInteract += door.OnEnemyDoorInteract;
            _myOwner.DoorInteract();
        }
    }
}
