// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package simple_example

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestSimpleExample(t *testing.T) {
	// Initializes the test using the example directory
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		// Verify no drift happens after terraform apply
		bpt.DefaultVerify(assert)

		// Get outputs from the Terraform example
		projectID := bpt.GetStringOutput("project_id")
		poolName := bpt.GetStringOutput("ca_pool_name")
		location := "us-central1"

		// Run a gcloud command to inspect the newly created Private CA Pool
		poolOp := gcloud.Runf(t, "privateca pools describe %s --location %s --project %s", poolName, location, projectID)

		// Assert the Tier matches our example configuration (enterprise_tier = false => DEVOPS)
		assert.Equal("DEVOPS", poolOp.Get("tier").String(), "CA Pool tier should be DEVOPS")

		// Assert the name is correct
		expectedName := fmt.Sprintf("projects/%s/locations/%s/caPools/%s", projectID, location, poolName)
		assert.Equal(expectedName, poolOp.Get("name").String(), "CA Pool full name should match")
	})

	bpt.Test()
}
